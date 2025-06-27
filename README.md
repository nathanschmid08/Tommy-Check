<p align="center">
  <img src="md/font.png" alt="Tommy Check"/>
</p>

This script is a colorful, interactive terminal tool for displaying system information on Linux. It uses ANSI color codes and Unicode characters to create stylish status displays with gradients and progress bars – completely without external libraries.

## 🔧 Features

* 🌈 **RGB & Gradient Output** in terminal (True Color)
* 📊 **RAM and SWAP usage** with color-coded progress bars
* 💾 Display of:
   * Total memory, free and used RAM
   * Caches, buffers, SWAP size & usage
   * CPU model & count
   * Runtime/Uptime
   * Load (Load Average)
   * Available network interfaces
   * Disk space on `/`
* 🖼️ ASCII art header in Nixie style
* 🎨 Gradient text and color status messages based on load
* ✨ Modern TUI design with Unicode frames and dynamic layout

## 🖥️ Example Display

```yaml
╭──────────────────────────────────────────────────────────────────────────────╮
│ MEMORY STATUS                                                                │
├──────────────────────────────────────────────────────────────────────────────┤
│ Usage: 68% [████████████████████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░]│
│ Used: 5600MB Available: 2600MB                                               │
│ Total: 8192MB Cached: 512MB Buffers: 128MB                                   │
│ Status: Getting a bit full, but okay                                         │
╰──────────────────────────────────────────────────────────────────────────────╯
```

## 🚀 Requirements

* **Perl** (v5 recommended)
* Linux system with `/proc/` available
* Supporting terminal with True Color (e.g. `alacritty`, `gnome-terminal`, `iTerm2`, ...)

## ▶️ Usage

1. Download `tommy.pl` and place it somewhere like `~/scripts/tommy.pl`.

2. Open your terminal and add this alias to your `.bashrc` (or `.zshrc` if you're using zsh):

   ```bash
   nano ~/.bashrc
   ```
   
   Then add the following line:
   
   ```bash
   alias tommy-check='perl ~/scripts/tommy.pl'
   ```

3. Save and close the file, then reload it:

   ```bash
   source ~/.bashrc
   ```

4. You can now check a Perl script by running:

   ```bash
   tommy-check
   ```

⚠️ Make sure to run the script in a terminal with 24-bit color support, otherwise colors may be incorrect.

## 📁 Contents

* `system_viewer.pl`: Main script
* Color and rendering functions for RGB, HSV, gradients
* Functions for formatting boxes and progress bars
* RAM/SWAP/CPU/Uptime/Disk/Network parsing directly from `/proc`

## 🧠 Motivation

This script is both a practical terminal monitoring solution and a graphical Perl demo project. The goal was to combine a modern, aesthetically pleasing text UI with low-level info – completely without external dependencies.
