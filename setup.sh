#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Exiting installation."
    exit 1
fi

# Variables
declare -A packages=(
    ["librewolf"]=false
    ["jetbrains_toolbox"]=false
    ["temurin"]=false
    ["lua"]=false
    ["spotify"]=false
    ["steam"]=false
    ["thunderbird"]=false
    ["discord"]=false
    ["obs"]=false
    ["boxes"]=false
)

error_count=0
declare -A error_log

# Utility Functions
print_progress() {
    local message="$1"
    local depth="$2"
    local indent=""
    for ((i = 0; i < depth - 1; i++)); do
        indent="    │$indent"
    done
    echo "$indent├── [*] $message"
}

print_result() {
    local success="$1"
    local message="$2"
    local depth="$3"
    local error_output="${4:-}"
    local indent=""
    for ((i = 0; i < depth - 1; i++)); do
        indent="    │$indent"
    done

    if [ "$success" = true ]; then
        echo "$indent├── [+] $message"
    else
        echo "$indent├── [-] $message"
        if [ -n "$error_output" ]; then
            echo "$indent    Error: $error_output"
        fi
        ((error_count++))
        error_log["$message"]="$error_output"
    fi
}

ask_install() {
    local package="$1"
    echo "Do you want to install $package? (y/n)"
    read -r response
    if [ "$response" = "y" ]; then
        packages["$package"]=true
    fi
}

install_package() {
    local pkg_name="$1"
    local install_cmd="$2"
    print_progress "Installing $pkg_name" 2
    if eval "$install_cmd"; then
        print_result true "$pkg_name installed" 2
    else
        print_result false "$pkg_name installation failed" 2
    fi
}

# Main
clear
stty -echo
echo "============== Vega =============="
echo "====== Authors: VegaUp Team ======"
echo "====== Debian Autoconfigure ======"
echo ""

echo "Starting in 3 seconds..."
sleep 3
stty echo

# Ask for package installation
for pkg in "${!packages[@]}"; do
    ask_install "$pkg"
done

stty -echo

print_progress "VegaUp Installation Starting" 0
install_package "System Updates" "apt update -y && apt upgrade -y"
install_package "Core Dependencies" "apt install -y curl extrepo snapd make"

print_progress "Setting up Package Managers" 1

if apt install -y flatpak plasma-discover-backend-flatpak > /dev/null 2>&1; then
    print_result true "Flatpak installed" 2
    if flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo > /dev/null 2>&1; then
        print_result true "Flathub repository added" 2
    else
        print_result false "Flathub repository failed" 2
    fi
else
    print_result false "Flatpak installation failed" 2
fi

print_progress "Installing Development Tools" 1

if [ "${packages["clang"]}" = true ]; then
    install_package "apt install -y clang"
fi

if [ "${packages["pkg_config"]}" = true ]; then
    install_package "apt install -y pkg-config"
fi

if [ "${packages["lua"]}" = true ]; then
    install_package "apt install -y lua5.4"
fi

if [ "${packages["temurin"]}" = true ]; then
    install_package "Temurin 21" "wget -q https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz -P /tmp/ && tar -xvzf /tmp/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz -C /opt/java/ && ln -sf /opt/java/jdk-21.0.5+11/bin/* /usr/local/bin/"
fi

if [ "${packages["jetbrains_toolbox"]}" = true ]; then
    install_package "JetBrains Toolbox" "wget -q https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.2.35332.tar.gz -P /tmp/ && tar -xvzf /tmp/jetbrains-toolbox-2.5.2.35332.tar.gz -C /opt/ && ln -sf /opt/jetbrains-toolbox-2.5.2.35332/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox"
fi

print_progress "Installing Applications" 1

if [ "${packages["librewolf"]}" = true ]; then
    install_package "LibreWolf" "extrepo enable librewolf && apt update && apt install -y librewolf"
fi

if [ "${packages["spotify"]}" = true ]; then
    install_package "Spotify" "snap install spotify"
fi

if [ "${packages["steam"]}" = true ]; then
    install_package "Steam" "snap install steam"
fi

if [ "${packages["thunderbird"]}" = true ]; then
    install_package "Thunderbird" "snap install thunderbird"
fi

if [ "${packages["discord"]}" = true ]; then
    install_package "Discord" "flatpak install -y flathub com.discordapp.Discord"
fi

if [ "${packages["obs"]}" = true ]; then
    install_package "OBS Studio" "flatpak install -y flathub com.obsproject.Studio"
fi

if [ "${packages["boxes"]}" = true ]; then
    install_package "GNOME Boxes" "flatpak install -y flathub org.gnome.Boxes"
fi

# Final Setup
print_progress "Final Setup Steps" 1
print_progress "Creating Python Symlink" 2

if ln -sf /usr/local/bin/python3 /usr/local/bin/python > /dev/null 2>&1; then
    print_result true "Python symlink created" 2
else
    print_result false "Python symlink creation failed" 2
fi

# Update Flatpak Packages
print_progress "Updating Flatpak Packages" 2

if flatpak update -y > /dev/null 2>&1; then
    print_result true "Flatpak packages updated" 2
else
    print_result false "Flatpak packages update failed" 2
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

echo "System reboot required to complete setup. Press Enter to reboot..."
read -r
reboot
