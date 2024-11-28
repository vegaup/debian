#!/bin/bash

# Check for sudo/root access
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Exiting installation."
    exit 1
fi

# Load VegaUp Library
if [ ! -f "/tmp/vegaup/lib/utility.sh" ]; then
    mkdir -p /tmp/vegaup/lib
    curl -fsSL https://raw.githubusercontent.com/VegaUp/VegaUp/main/lib/utility.sh -o "/tmp/vegaup/lib/utility.sh" >/dev/null 2>&1
fi
source "/tmp/vegaup/lib/utility.sh"

##! Main Entrypoint !##
clear
stty -echo
echo "============== Vega =============="
echo "====== Authors: VegaUp Team ======"
echo "====== Debian Autoconfigure ======"
echo ""

print_progress "VegaUp Installation Starting" 0
print_progress "Installing System Updates" 1

if apt update >/dev/null 2>&1 && apt upgrade -y >/dev/null 2>&1; then
    print_result true "System packages updated" 1
else
    print_result false "System packages update failed" 1
fi

print_progress "Installing Core Dependencies" 1

if apt-get install -y extrepo snapd make >/dev/null 2>&1; then
    print_result true "Core dependencies installed" 1
else
    print_result false "Core dependencies installation failed" 1
fi

print_progress "Setting up Package Managers" 1

if error_output=$(apt install -y flatpak plasma-discover-backend-flatpak 2>&1 >/dev/null); then
    print_result true "Flatpak installed" 2
    if error_output=$(flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>&1 >/dev/null); then
        print_result true "Flathub repository added" 2
    else
        print_result false "Flathub repository failed" 2 "$error_output"
    fi
else
    print_result false "Flatpak installation failed" 2 "$error_output"
fi

if error_output=$(apt-get install snapd 2>&1 >/dev/null); then
    print_result true "Snap installed" 2
else
    print_result false "Snap installation failed" 2 "$error_output"
fi

print_progress "Installing Development Tools" 1

if [ "${packages["Clang"]}" = true ]; then
    install_package "Clang" "apt install -y clang"
fi

if [ "${packages["PKG Config"]}" = true ]; then
    install_package "PKG-Config" "apt install -y pkg-config"
fi

if [ "${packages["Lua 5.4"]}" = true ]; then
    install_package "Lua 5.4" "apt install -y lua5.4"
fi

if [ "${packages["Temurin 21"]}" = true ]; then
    if [ ! -d "/opt/java" ]; then
        mkdir /opt/java
    fi

    install_package "Temurin 21" "curl -L -o /tmp/temurin21.tar.gz https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz && tar -xvzf /tmp/temurin21.tar.gz -C /opt/java/ && ln -sf /opt/java/jdk-21.0.5+11/bin/* /usr/local/bin/"
fi

if [ "${packages["Jetbrains Toolbox"]}" = true ]; then
    if [ ! -d "/opt" ]; then
        mkdir /opt
    fi

    install_package "JetBrains Toolbox" "curl -L -o /tmp/jetbrains-toolbox.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.2.35332.tar.gz && tar -xvzf /tmp/jetbrains-toolbox.tar.gz -C /opt/ && ln -sf /opt/jetbrains-toolbox-2.5.2.35332/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox"
fi

if [ "${packages["Fast Node Manager"]}" = true ]; then
    install_package "Fast Node Manager" "
        sudo -u $SUDO_USER bash -c 'curl -fsSL https://fnm.vercel.app/install | bash && source $HOME/.bashrc'
        wait $1
    "
fi

if [ "${packages["Zig"]}" = true ]; then
    install_package "Zig" "snap install --beta --classic zig"
fi

print_progress "Installing Applications" 1

if [ "${packages["Librewolf"]}" = true ]; then
    install_package "LibreWolf" "extrepo enable librewolf && apt update && apt install -y librewolf"
fi

if [ "${packages["Spotify"]}" = true ]; then
    install_package "Spotify" "snap install spotify"
fi

if [ "${packages["Steam"]}" = true ]; then
    install_package "Steam" "snap install steam"
fi

if [ "${packages["Thunderbird"]}" = true ]; then
    install_package "Thunderbird" "snap install thunderbird"
fi

if [ "${packages["Discord"]}" = true ]; then
    install_package "Discord" "flatpak install -y flathub com.discordapp.Discord"

    if [ "${packages["Vencord"]}" = true ]; then
        # TODO: Handle errors and make it auto-close console whenever vencord installation is done.
        install_package "Vencord" "sudo -u $SUDO_USER bash -c 'if command -v konsole &>/dev/null; then
                konsole --hold -e sh -c \"curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh > /tmp/vencord_installer.sh && \
                bash /tmp/vencord_installer.sh && \
                rm /tmp/vencord_installer.sh\";
            fi'"
    fi
fi

if [ "${packages["OBS"]}" = true ]; then
    install_package "OBS Studio" "flatpak install -y flathub com.obsproject.Studio"
fi

if [ "${packages["GNOME Boxes"]}" = true ]; then
    install_package "GNOME Boxes" "flatpak install -y flathub org.gnome.Boxes"
fi

# Final Setup
print_progress "Final Setup Steps" 1
print_progress "Creating Python Symlink" 2

error_output=$(ln -sf /usr/local/bin/python3 /usr/local/bin/python 2>&1 >/dev/null)
if [ $? -eq 0 ]; then
    print_result true "Python symlink created" 2
else
    print_result false "Python symlink creation failed" 2 "$error_output"
fi

# Update Flatpak Packages
print_progress "Updating Flatpak Packages" 2

error_output=$(flatpak update -y 2>&1 >/dev/null)
if [ $? -eq 0 ]; then
    print_result true "Flatpak packages updated" 2
else
    print_result false "Flatpak packages update failed" 2 "$error_output"
fi

print_result true "Installation Complete" 0
stty echo

if [ $error_count -gt 0 ]; then
    echo ""
    echo "$error_count problem(s) encountered during installation!"
    echo "Press 1 to show error log, or Enter to continue..."
    read -r choice
    if [ "$choice" = "1" ]; then
        echo ""
        echo "Installation Error Log:"
        echo "======================"
        for failed_item in "${!error_log[@]}"; do
            echo ""
            echo "Error in: $failed_item"
            echo "------------------------"
            echo "${error_log[$failed_item]}"
            echo "------------------------"
        done
        echo ""
        echo "Press Enter to continue..."
        read -r
    fi
fi

rm -rf /tmp/vegaup
echo "System reboot required to complete setup. Press Enter to reboot..."
read -r
reboot
