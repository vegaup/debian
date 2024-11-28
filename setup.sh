#!/bin/bash

# Variables
librewolf=false
jetbrains_toolbox=false
temurin=false
lua=false
spotify=false
steam=false
thunderbird=false
discord=false
# vencord=false
obs=false
boxes=false
error_count=0
declare -A error_log

# Utils
print_progress() {
    local message="$1"
    local depth="$2"

    for ((i=0; i<depth-1; i++)); do
        echo -n "    │"
    done

    if [ "$depth" -eq 0 ]; then
        echo -n "[/] "
    else
        echo -n "    ├── [*] "
    fi
    echo "$message"
}

print_result() {
    local success="$1"
    local message="$2"
    local depth="$3"
    local error_output="$4"

    for ((i=0; i<depth-1; i++)); do
        echo -n "    │"
    done

    if [ "$depth" -eq 0 ]; then
        if [ "$success" = true ]; then
            echo -n "[+] "
        else
            echo -n "[-] "
            ((error_count++))
            error_log["$message"]="$error_output"
        fi
    else
        if [ "$depth" -gt 2 ]; then
            echo -n "    └── "
        else
            echo -n "    ├── "
        fi
        if [ "$success" = true ]; then
            echo -n "[+] "
        else
            echo -n "[-] "
            ((error_count++))
            error_log["$message"]="$error_output"
        fi
    fi
    echo "$message"
}

clear

if [ "$(id -u)" != "0" ]; then
    echo "Pwease run this scwipt with sudo to proceed with the installation."
    echo "This scwipt must be run as root. Exiting installation."
    exit 1
fi

echo "============== Vega =============="
echo "====== Authors: VegaUp Team ======"
echo "====== Debian Autoconfigure ======"

echo ""
echo "Starting in 5 seconds..."
sleep 5

echo "Do you want to install LibreWolf? (y/n)"
read -r librewolf

if [ "$librewolf" = "y" ]; then
    librewolf=true
fi

echo "Do you want to install JetBrains Toolbox? (y/n)"
read -r jetbrains_toolbox

if [ "$jetbrains_toolbox" = "y" ]; then
    jetbrains_toolbox=true
fi

echo "Do you want to install Temurin 21? (y/n)"
read -r temurin

if [ "$temurin" = "y" ]; then
    temurin=true
fi

echo "Do you want to install Clang? (y/n)"
read -r clang

if [ "$clang" = "y" ]; then
    clang=true
fi

echo "Do you want to install pkg-config? (y/n)"
read -r pkg_config

if [ "$pkg_config" = "y" ]; then
    pkg_config=true
fi

echo "Do you want to install Lua 5.4? (y/n)"
read -r lua

if [ "$lua" = "y" ]; then
    lua=true
fi

echo "Do you want to install Spotify? (y/n)"
read -r spotify

if [ "$spotify" = "y" ]; then
    spotify=true
fi

echo "Do you want to install Steam? (y/n)"
read -r steam

if [ "$steam" = "y" ]; then
    steam=true
fi

echo "Do you want to install Thunderbird? (y/n)"
read -r thunderbird

if [ "$thunderbird" = "y" ]; then
    thunderbird=true
fi

echo "Do you want to install Discord? (y/n)"
read -r discord

if [ "$discord" = "y" ]; then
    discord=true
    # echo "Do you want to install Vencord? (y/n)"
    #
    # read -r vencord
    #
    # if [ "$vencord" = "y" ]; then
    #     vencord=true
    # fi
fi

echo "Do you want to install OBS Studio? (y/n)"
read -r obs

if [ "$obs" = "y" ]; then
    obs=true
fi

echo "Do you want to install GNOME Boxes? (y/n)"
read -r boxes

if [ "$boxes" = "y" ]; then
    boxes=true
fi

stty -echo

clear
echo "============== Vega =============="
echo "====== Authors: VegaUp Team ======"
echo "====== Debian Autoconfigure ======"
echo ""

print_progress "VegaUp Installation Starting" 0

print_progress "System Updates" 1
if apt update > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1; then
    print_result true "System packages updated" 1
else
    print_result false "System packages update failed" 1
fi

print_progress "Installing Core Dependencies" 1
if apt-get install -y curl extrepo snapd make > /dev/null 2>&1; then
    print_result true "Core dependencies installed" 1
else
    print_result false "Core dependencies installation failed" 1
fi

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
if [ "$clang" = true ]; then
    print_progress "Installing Clang" 2
    if apt install -y clang > /dev/null 2>&1; then
        print_result true "Clang installed" 2
    else
        print_result false "Clang installation failed" 2
    fi
fi

if [ "$pkg_config" = true ]; then
    print_progress "Installing pkg-config" 2
    if apt install -y pkg-config > /dev/null 2>&1; then
        print_result true "pkg-config installed" 2
    else
        print_result false "pkg-config installation failed" 2
    fi
fi

if [ "$lua" = true ]; then
    print_progress "Installing Lua 5.4" 2
    if apt install -y lua5.4 > /dev/null 2>&1; then
        print_result true "Lua installed" 2
    else
        print_result false "Lua installation failed" 2
    fi
fi

if [ "$temurin" = true ]; then
    print_progress "Installing Temurin 21" 2
    if wget -q https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz -P /tmp/ && \
       mkdir -p /opt/java/ && \
       tar -xvzf /tmp/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz -C /opt/java/ > /dev/null 2>&1; then
        for bin_file in /opt/java/jdk-21.0.5+11/bin/*; do
            ln -sf "$bin_file" /usr/local/bin/
        done
        rm /tmp/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
        print_result true "Temurin 21 installed" 2
    else
        print_result false "Temurin 21 installation failed" 2
    fi
fi

if [ "$jetbrains_toolbox" = true ]; then
    print_progress "Installing JetBrains Toolbox" 2
    if wget -q https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.2.35332.tar.gz -P /tmp/ && \
       tar -xvzf /tmp/jetbrains-toolbox-2.5.2.35332.tar.gz -C /opt/ > /dev/null 2>&1 && \
       ln -sf /opt/jetbrains-toolbox-2.5.2.35332/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox; then
        rm /tmp/jetbrains-toolbox-2.5.2.35332.tar.gz
        print_result true "JetBrains Toolbox installed" 2
    else
        print_result false "JetBrains Toolbox installation failed" 2
    fi
fi

print_progress "Installing Applications" 1
if [ "$librewolf" = true ]; then
    print_progress "Installing LibreWolf" 2
    if extrepo enable librewolf > /dev/null 2>&1 && \
       apt-get update > /dev/null 2>&1 && \
       apt-get install -y librewolf > /dev/null 2>&1; then
        print_result true "LibreWolf installed" 2 true
    else
        print_result false "LibreWolf installation failed" 2 true
    fi
fi

if [ "$spotify" = true ]; then
    print_progress "Installing Spotify" 2
    if snap install spotify > /dev/null 2>&1; then
        print_result true "Spotify installed" 2
    else
        print_result false "Spotify installation failed" 2
    fi
fi

if [ "$steam" = true ]; then
    print_progress "Installing Steam" 2
    if snap install steam > /dev/null 2>&1; then
        print_result true "Steam installed" 2
    else
        print_result false "Steam installation failed" 2
    fi
fi

if [ "$thunderbird" = true ]; then
    print_progress "Installing Thunderbird" 2
    if snap install thunderbird > /dev/null 2>&1; then
        print_result true "Thunderbird installed" 2
    else
        print_result false "Thunderbird installation failed" 2
    fi
fi

if [ "$discord" = true ]; then
    print_progress "Installing Discord" 2
    error_output=$(flatpak install -y flathub com.discordapp.Discord 2>&1)
    if [ $? -eq 0 ]; then
        print_result true "Discord installed" 2
        # TODO: Decide if we want to keep this
        # if [ "$vencord" = true ]; then
        #     print_progress "Installing Vencord" 3
        #     error_output=$(curl -fsSL "https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh" | bash 2>&1) &
        #     vencord_pid=$!
        #     wait $vencord_pid
        #     if [ $? -eq 0 ]; then
        #         print_result true "Vencord installed" 3
        #     else
        #         print_result false "Vencord installation failed" 3 "$error_output"
        #     fi
        # fi
    else
        print_result false "Discord installation failed" 2 "$error_output"
    fi
fi

if [ "$obs" = true ]; then
    print_progress "Installing OBS Studio" 2
    if flatpak install -y flathub com.obsproject.Studio > /dev/null 2>&1; then
        print_result true "OBS Studio installed" 2
    else
        print_result false "OBS Studio installation failed" 2
    fi
fi

if [ "$boxes" = true ]; then
    print_progress "Installing GNOME Boxes" 2
    if flatpak install -y flathub org.gnome.Boxes > /dev/null 2>&1; then
        print_result true "GNOME Boxes installed" 2
    else
        print_result false "GNOME Boxes installation failed" 2
    fi
fi

print_progress "Final Setup Steps" 1
print_progress "Creating Python Symlink" 2
if ln -sf /usr/local/bin/python3 /usr/local/bin/python > /dev/null 2>&1; then
    print_result true "Python symlink created" 2
else
    print_result false "Python symlink creation failed" 2
fi

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
