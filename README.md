
# 🧵 MyTop - Custom System Monitor

**MyTop** is a lightweight, Bash-based system monitor that mimics the functionality of the Unix `top` command. It displays real-time information about system processes, CPU and memory usage, and allows interactive control over how processes are displayed.



## 🖥️ How to Use the Script

1. Make the script executable:
   ```bash
   chmod +x mytop.sh
   ```

2. Run the script:
   ```bash
   ./mytop.sh
   ```

3. Interact with the monitor using your keyboard (see below).



## 🧭 Command-line Options & Interactive Commands

The script runs in a loop and waits for user input after every refresh.

**Keybindings:**

| Key    | Action                             |
|--------|------------------------------------|
| `q`    | Quit the program                   |
| `M`    | Sort processes by **Memory usage** |
| `P`    | Sort processes by **PID**          |
| `T`    | Sort processes by **Running Time** |
| `Space`| Refresh process list               |
| `h`    | Show help message                  |

> ⚠️ Note: The space bar input is treated as a **NULL** character (empty input), and is used to refresh the display without changing sort mode.



## ⚙️ Implementation Details

- **Process Data:**
  - Uses the `ps` command with `--sort` to retrieve and sort process data.
  - Displays the following fields: `PID`, `USER`, `PRI`, `%CPU`, `%MEM`, `TIME`, `COMMAND`.

- **Color Coding:**
  - **Headers** are colored in **blue** for visibility.
  - **Processes**:
    - **System processes** (e.g., owned by `root`) are shown in **magenta**.
    - **User processes** are shown in **blue**.
  - **Memory Usage**:
    - **Green**: Low (<50%)
    - **Yellow**: Medium (50–80%)
    - **Red**: High (>80%)

- **Terminal Behavior:**
  - Captures single keystrokes using `stty` (no Enter needed).
  - Clears and redraws the screen using ANSI escape codes.
  - Manual formatting using `printf` ensures alignment.

- **Sorting:**
  - Controlled by a `sort_processes` function that adjusts based on key input.



## ⚠️ Known Limitations

- **TIME Precision:**
  - Uses the `time` field from `ps`, which has lower precision than `top`'s `TIME+`.

- **Redraw Behavior:**
  - The entire screen is redrawn on each refresh. Unlike `top`, which uses partial updates, this approach is less efficient.

- **Display Issues:**
  - Long usernames or commands may cause alignment problems.

- **No Mouse Support:**
  - This is a CLI-only tool; mouse or GUI interaction is not supported.



## 🚀 Future Improvements

- Add support for sorting by command name or priority.
- Visual CPU and memory bars.
- Improve precision of time values by parsing `/proc/[pid]/stat`.
- Add paging for large process lists.
- Add filters for user or command name.
