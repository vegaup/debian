# Vega Setup Script

A comprehensive setup script for Debian-based Linux distributions that installs and configures essential development tools and applications.

## Prerequisites

- Debian-based Linux distribution (e.g., Debian, Ubuntu)
- Root/sudo access
- Internet connection

## What Gets Installed

### Package Managers & Core Utilities
- Flatpak with Plasma Discover Backend
- Snapd
- Extrepo
- Curl

### Browsers
- LibreWolf

### Development Tools
- JetBrains Toolbox
- OpenJDK (Temurin 21)
- Python 3 (with symbolic link)
- Lua 5.4
- Clang
- pkg-config

### Applications
- Spotify
- Steam
- Thunderbird
- Discord (with Vencord)
- OBS Studio
- GNOME Boxes (Virtualization)

## Installation

1. Clone this repository or download the setup script
2. Make the script executable:
   ```bash
   chmod +x setup.sh
   ```
3. Run the script:
   ```bash
   ./setup.sh
   ```

⚠️ **Note**: The script requires root privileges and will prompt for your password.

## Post-Installation

- The system will automatically reboot after installation to complete the setup
- After reboot, you may need to configure individual applications
- JetBrains Toolbox can be launched from the command line using `jetbrains-toolbox`

## Updates

The script includes updates for:
- System packages
- Flatpak packages
- Snap packages

## Additional Notes

- Python is symbolically linked so `python` command points to `python3`
- Java (OpenJDK 21) is installed in `/opt/java/` with binaries linked to `/usr/local/bin/`
- Vencord is automatically installed over Discord for enhanced functionality

## License

[MIT](LICENSE.md)

## Contributing

Feel free to open issues or submit pull requests if you have suggestions for improvements.
