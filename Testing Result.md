# Testing Results: MyTop vs. top Command

## Introduction
This document compares the functionality and performance of the custom **MyTop** system monitor script with the standard **top** command.

Both tools are run side by side, and the differences in their outputs are examined.

## Screenshots

Below are the screenshots of **MyTop** and **top** running simultaneously on the system:

![Top Command vs. MyTop](https://github.com/Speedylo/MyTop/blob/d6cae1afd4190085e46e206acee9672423dbf81c/Testing%20Result.png)

## Comparison Criteria

### 1. **CPU and Memory Usage Display**
- **MyTop**: Displays CPU and memory usage of each process, allowing sorting by different metrics (CPU, memory, PID, etc.).
- **top**: Provides similar metrics but updates in real-time with precision (TIME+).

### 2. **Sorting**
- **MyTop**: Can sort processes based on user input (`M` for memory, `P` for PID, `T` for time).
- **top**: Allows real-time sorting, but some behaviors (like sorting by memory) might be easier to navigate in **top**.

### 3. **Redraw Behavior**
- **MyTop**: Redraws the entire screen on each refresh cycle, unlike **top** which updates values in-place.
- **top**: Uses efficient buffering to update only the values, maintaining a smoother interface.

### 4. **TIME Precision**
- **MyTop**: Displays time precision similar to `ps`'s `time` field, which may not match **top**'s `TIME+` in terms of precision.
- **top**: Provides higher precision (`TIME+`), which displays time in a more detailed format.

## Known Limitations of MyTop
- **TIME Precision**: MyTop uses `ps`'s `time` field, which has lower precision than **top**'s `TIME+`.
- **Redraw Behavior**: The entire screen is redrawn, unlike **top**'s in-place value update.
- **Display Issues**: Long usernames or command names may misalign columns.
- **No Mouse Support**: MyTop is a CLI-based tool, unlike GUI tools.

## Future Improvements
- Add support for sorting by command name or priority.
- Implement memory and CPU usage bars for better visualization.
- Enhance the precision of TIME using `/proc` parsing.
- Implement paging for systems with large process lists.
- Allow filtering by user or command name.

## Conclusion
Both **MyTop** and **top** provide useful insights into system processes and resource usage, but **top** offers more precision and smooth updates. However, **MyTop** offers flexibility and customizability in terms of sorting and display, providing a lightweight, Bash-based alternative.
