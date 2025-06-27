<h1 align="center">
  <img src="md/font.png" alt="Tommy Check Icon"> 
</h1>
<p align="center">
  <img src="https://img.shields.io/badge/Status-Stable-green" alt="Status">
  <img src="https://img.shields.io/badge/Version-1.0-blue" alt="Version">
  <img src="https://img.shields.io/badge/Language-Perl-purple" alt="Language">
</p>
<div align="center">
  <h3>
    <strong>Colorful, interactive terminal tool for displaying system information on Linux</strong>
  </h3>
  <h4>
    <em>Stylish • Native • Zero Dependencies</em>
  </h4>
</div>
<p align="center">
  <a href="#-features"><b>🔧 Features</b></a> •
  <a href="#-getting-started"><b>🚀 Getting Started</b></a> •
  <a href="#-example"><b>🖥️ Examples</b></a> •
  <a href="#-contents"><b>📁 Contents</b></a>
</p>
<hr>
<img align="right" src="md/Tommy.png" width="150">

## 💡 About Tommy Check

Tommy Check is a colorful, interactive terminal tool for displaying system information on Linux. It uses ANSI color codes and Unicode characters to create stylish status displays with gradients and progress bars – completely without external libraries.

> ✨ Modern TUI design with Unicode frames and dynamic layout

<hr>

## 🔧 Features

<table>
  <tr>
    <td width="200"><h3 align="center">🌈</h3><h3 align="center"><b>RGB & Gradients</b></h3></td>
    <td>True Color terminal output with stunning gradient effects</td>
  </tr>
  <tr>
    <td width="200"><h3 align="center">📊</h3><h3 align="center"><b>System Monitoring</b></h3></td>
    <td>RAM, SWAP, CPU, disk space, and network interface tracking</td>
  </tr>
  <tr>
    <td width="200"><h3 align="center">🎨</h3><h3 align="center"><b>Smart Visuals</b></h3></td>
    <td>Color-coded progress bars and status messages based on load</td>
  </tr>
  <tr>
    <td width="200"><h3 align="center">🖼️</h3><h3 align="center"><b>ASCII Art</b></h3></td>
    <td>Stylish Nixie-style header with modern Unicode frames</td>
  </tr>
</table>

<hr>

## 🖥️ Example

### Terminal Output
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

### System Information Display
- **Memory**: Total, free, used RAM with caches and buffers
- **SWAP**: Size and usage statistics  
- **CPU**: Model information and core count
- **System**: Runtime/Uptime and Load Average
- **Network**: Available network interfaces
- **Storage**: Disk space usage on root partition

<hr>

## 🚀 Getting Started

### Requirements
- **Perl** (v5 recommended)
- Linux system with `/proc/` available
- Terminal with True Color support (alacritty, gnome-terminal, iTerm2)

### Installation
1. Download `tommy.pl` and place it in `~/scripts/tommy.pl`
2. Add alias to your shell configuration:
   ```bash
   echo "alias tommy-check='perl ~/scripts/tommy.pl'" >> ~/.bashrc
   source ~/.bashrc
   ```
3. Run the tool:
   ```bash
   tommy-check
   ```

> ⚠️ Ensure your terminal supports 24-bit color for optimal display

<hr>

## 📁 Contents

- `system_viewer.pl` - Main monitoring script
- Color and rendering functions for RGB, HSV, gradients  
- Box formatting and progress bar utilities
- Native `/proc` parsing for system metrics

<hr>

### 🧠 Motivation

Tommy Check combines practical terminal monitoring with aesthetic appeal, demonstrating modern Perl capabilities for creating beautiful text interfaces without external dependencies.

<div align="center">
  <p><i>© 2025 System Monitoring Made Beautiful</i></p>
</div>
