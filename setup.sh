#!/bin/bash

echo "Pwease give me your password, I want your information <3"
sudo su

echo "Updating package list and upgrading installed packages..."
apt update && apt upgrade -y

echo "Installing dependencies..."
apt-get install -y curl extrepo snapd make clang pkg-config

echo "Installing Flatpak and Plasma Discover Backend..."
apt install -y flatpak plasma-discover-backend-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "Installing snapd, extrepo, and curl..."
apt-get install -y curl extrepo snapd

echo "Installing librewolf..."
extrepo enable librewolf
apt --allow-releaseinfo-change update
apt install -y librewolf

echo "Installing applications (Spotify, Steam, Thunderbird, OBS, and Discord)..."
snap install spotify
snap install steam
snap install thunderbird
flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub com.obsproject.Studio

echo "Install boxes virtualisation..."
flatpak install -y flathub org.gnome.Boxes

echo "Updating Flatpak packages..."
flatpak update -y

echo "Applying vencord over Discord..."
sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"

echo "Downloading and installing JetBrains Toolbox..."
wget -q https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.2.35332.tar.gz -P /tmp/
tar -xvzf /tmp/jetbrains-toolbox-2.5.2.35332.tar.gz -C /opt/
ln -sf /opt/jetbrains-toolbox-2.5.2.35332/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox
rm /tmp/jetbrains-toolbox-2.5.2.35332.tar.gz

echo "Downloading and installing Temurin 21 (OpenJDK)..."
wget -q https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz -P /tmp/
mkdir /opt/java/
tar -xvzf /tmp/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz -C /opt/java/
for bin_file in /opt/java/jdk-21.0.5+11/bin/*; do
    ln -sf "$bin_file" /usr/local/bin/
done
rm /tmp/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz

echo "Adding symbolic link for python3..."
ln -sf /usr/local/bin/python3 /usr/local/bin/python

echo "Installing lua...."
apt install lua5.4

echo "System reboot required to complete setup. Press Enter to reboot ... "
read -r
sudo reboot
