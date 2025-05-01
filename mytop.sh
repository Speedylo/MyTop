#!/bin/bash

# Save terminal settings
stty_orig=$(stty -g)

# Setup trap to restore terminal on exit
trap 'stty "$stty_orig"; clear; exit' INT TERM EXIT

# Set terminal to raw mode (no echo, single character input)
stty -echo -icanon time 0 min 0

# Function to handle keypresses
handle_keypress() {
    # Quit
    if [[ $key == "q" ]]; then
        clear
        stty "$stty_orig"
        exit 0
    # Space bar || Sort by Memory Usage || Sort by PID || Sort by Time
    elif [[ -z $key || $key == "M" || $key == "P" || $key == "T" ]]; then
        refresh_now=1
    # Help
    elif [[ $key == "h" ]]; then
        echo "Help: Press 'q' to quit, 'space' to refresh, 'h' for help."
    fi
}

get_cpu_usage() {
    # Read first sample
    read cpu user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1 guest1 guest_nice1 < /proc/stat
    total_before=$((user1 + nice1 + system1 + idle1 + iowait1 + irq1 + softirq1))
    user_before=$((user1 + nice1))
    system_before=$system1

    sleep 0.5

    # Read second sample
    read cpu user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 guest2 guest_nice2 < /proc/stat
    total_after=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2))
    user_after=$((user2 + nice2))
    system_after=$system2

    # Differences
    total_diff=$((total_after - total_before))
    user_diff=$((user_after - user_before))
    system_diff=$((system_after - system_before))

    # Avoid division by zero
    if [ "$total_diff" -eq 0 ]; then
        cpu_user="0.0"
        cpu_system="0.0"
    else
        cpu_user=$(printf "%.1f" "$(echo "scale=2; 100 * $user_diff / $total_diff" | bc)")
        cpu_system=$(printf "%.1f" "$(echo "scale=2; 100 * $system_diff / $total_diff" | bc)")
    fi
}

get_mem_usage(){
    mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_free=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    mem_used=$((mem_total - mem_free))

    # Convert to MB
    mem_total_mb=$((mem_total / 1024))
    mem_used_mb=$((mem_used / 1024))
    mem_free_mb=$((mem_free / 1024))

    # Convert to %
    mem_usage_percent=$(echo "scale=1; 100 * $mem_used / $mem_total" | bc)
}

sort_processes() {
    case $key in
        "M") ps -eo pid,user,pri,%cpu,%mem,time,comm --sort=-%mem --no-header;; #Memory Usage
        "P") ps -eo pid,user,pri,%cpu,%mem,time,comm --sort=pid --no-header;; #PID
        "T") ps -eo pid,user,pri,%cpu,%mem,time,comm --sort=-time --no-header;; #Time
        *) ps -eo pid,user,pri,%cpu,%mem,time,comm --sort=-%cpu --no-header;; #CPU Usage (Default)
    esac
}

print_process_list() {

    echo ""
    echo -e "\e[1;34mTop Processes by CPU Usage (Press 'M' for memory, 'P' for PID, or 'T' for time)\e[0m"
    echo ""
    
    # Colored Column Headers
    printf "\e[1m%-8s %-10s %-5s %-6s %-6s %-10s %-s\e[0m\n" "PID" "USER" "PRI" "%CPU" "%MEM" "TIME" "COMMAND"

    sort_processes | while read -r pid user pri cpu mem time comm; do
        # Determine whether it's a system or user process by checking UID
        uid=$(id -u "$user" 2>/dev/null)
        
        # Color based on UID: <1000 (system) or >=1000 (user)
        if [[ -z "$uid" || "$uid" -lt 1000 ]]; then
            color="\e[35m"  # Purple for system processes
        else
            color="\e[36m"  # Cyan for user processes
        fi
        printf "${color}%-8s %-10s %-5s %-6s %-6s %-10s %-s\e[0m\n" "$pid" "$user" "$pri" "$cpu" "$mem" "$time" "$comm"
    done
}

# Function to colorize CPU usage
colorize_cpu_usage() {
    local cpu=$1
    if (( $(echo "$cpu > 80" | bc -l) )); then
        echo -e "\e[31m$cpu%\e[0m"  # Red for high CPU usage (>80%)
    elif (( $(echo "$cpu > 50" | bc -l) )); then
        echo -e "\e[33m$cpu%\e[0m"  # Yellow for medium CPU usage (50-80%)
    else
        echo -e "\e[32m$cpu%\e[0m"  # Green for low CPU usage (<50%)
    fi
}

# Function to colorize memory usage
colorize_mem_usage() {
    local mem=$1
    if (( $(echo "$mem > 80" | bc -l) )); then
        echo -e "\e[31m$mem%\e[0m"  # Red for high memory usage (>80%)
    elif (( $(echo "$mem > 50" | bc -l) )); then
        echo -e "\e[33m$mem%\e[0m"  # Yellow for medium memory usage (50-80%)
    else
        echo -e "\e[32m$mem%\e[0m"  # Green for low memory usage (<50%)
    fi
}

# Print CPU and Memory usage with color
print_colored_header() {      
    get_cpu_usage
    get_mem_usage

    echo -e "\e[1;34m=== MyTop - Custom System Monitor ===\e[0m"
    
    #Date and Uptime
    echo -e "\e[93mCurrent Time:\e[0m $(date)"
    echo -e "\e[93mUptime:\e[0m $(uptime -p)"

    #Load Averages
    read load1 load5 load15 rest < /proc/loadavg
    echo -e "\e[93mLoad Average:\e[0m $load1 (1m), $load5 (5m), $load15 (15m)"

    #Processes
    total_processes=$(ps -e --no-headers | wc -l)
    running=$(ps -e -o stat --no-headers | grep -c '^R')
    sleeping=$(ps -e -o stat --no-headers | grep -c '^S')
    stopped=$(ps -e -o stat --no-headers | grep -c '^T')
    echo -e "\e[93mProcesses:\e[0m Total=$total_processes, Running=$running, Sleeping=$sleeping, Stopped=$stopped"

    #CPU Usage (User and System)
    echo -e "\e[93mCPU Usage:\e[0m $(colorize_cpu_usage $cpu_user) user, $(colorize_cpu_usage $cpu_system) system"

    #Memory Usage
    mem_color=$(colorize_mem_usage "$mem_usage_percent")
    echo -e "\e[93mMemory Usage:\e[0m ${mem_used_mb}MB used / ${mem_total_mb}MB total (${mem_free_mb}MB free) - $mem_color used"
}

# Main loop
while true; do
    clear
    print_colored_header
    print_process_list

    # Wait for 5 seconds total, checking every 0.1 second
    refresh_now=0
    for ((i=0; i<50; i++)); do
        if read -t 0.1 -n 1 -s key; then
            handle_keypress
            if [[ $refresh_now -eq 1 ]]; then
               break
            fi
        fi
    done
done