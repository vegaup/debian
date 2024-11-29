#!/bin/bash

echo "Please enter your password to grant root access:"
sudo clear

echo "╔═══════════════════════════════╗"
echo "║         VegaUp Setup          ║" 
echo "║    Created by VegaUp Team     ║"
echo "║   Debian Auto-Configuration   ║"
echo "╚═══════════════════════════════╝"
echo ""
echo "You will be asked questions to configure your system."
read -r -p "Press Enter to continue..."

while true; do
    clear
    echo "╔══════════════════════════╗"
    echo "║   Browser Installation   ║"
    echo "║   ────────────────────   ║"
    echo "║    1. Mozilla Firefox    ║"
    echo "║    2. Microsoft Edge     ║"
    echo "║    3. Brave Browser      ║"
    echo "║    4. Google Chrome      ║"
    echo "╚══════════════════════════╝"
    echo ""
    read -r -p "What browser would you like? (Firefox/Edge/Brave/Chrome): " browser_choice
    case ${browser_choice,,} in
        firefox|1) browser_choice="Firefox"; break;;
        edge|2) browser_choice="Edge"; break;;
        brave|3) browser_choice="Brave"; break;;
        chrome|4) browser_choice="Chrome"; break;;
        *) echo "Invalid choice. Please select a valid browser..."; sleep 1;;
    esac
done

while true; do
    clear
    echo "╔═════════════════════════╗"
    echo "║    Package Managers     ║"
    echo "║    ────────────────     ║"
    echo "║  snap • flatpak • dnf   ║"
    echo "║  pacman • nala • brew   ║"
    echo "╚═════════════════════════╝"
    echo ""
    read -r -p "Enter the package managers you want. (e.g. 'snap flatpak'): " package_choices
    package_managers=()
    for choice in $package_choices; do
        case ${choice,,} in
            snap|snapd) package_managers+=("snap");;
            flatpak|flatpack|flathub) package_managers+=("flatpak");;
            dnf) package_managers+=("dnf");;
            pacman|packman) package_managers+=("pacman");;
            nala) package_managers+=("nala");;
            brew|homebrew) package_managers+=("brew");;
            *) echo "Invalid package manager: $choice. Skipping...";;
        esac
    done
    [ ${#package_managers[@]} -eq 0 ] && { echo "You didn't enter any valid package managers. Please try again..."; sleep 1; continue; }
    read -r -p "Are you happy with your choices? (y/n): " happy_choices
    [[ $happy_choices =~ ^[Yy]$ ]] && break
done

while true; do
    clear
    echo "╔═════════════════════════════╗"
    echo "║        Applications         ║"
    echo "║        ────────────         ║"
    echo "║  Steam • Spotify • Discord  ║"
    echo "║   Vencord • Thunderbird     ║"
    echo "║  OBS • Obsidian • KeePass   ║"
    echo "╚═════════════════════════════╝"
    echo ""
    read -r -p "Enter the applications you want (e.g. 'steam discord'): " app_choices
    applications=()
    for choice in $app_choices; do
        case ${choice,,} in
            steam) applications+=("Steam");;
            spotify) applications+=("Spotify");;
            discord) applications+=("Discord");;
            vencord) applications+=("Vencord");;
            thunderbird) applications+=("Thunderbird");;
            obs) applications+=("OBS");;
            obsidian) applications+=("Obsidian");;
            keepass|keepassxc) applications+=("KeePassXC");;
            *) echo "Invalid application: $choice. Skipping...";;
        esac
    done
    [ ${#applications[@]} -eq 0 ] && { echo "You didn't enter any valid applications. Please try again..."; sleep 1; continue; }
    read -r -p "Are you happy with your choices? (y/n): " happy_choices
    [[ $happy_choices =~ ^[Yy]$ ]] && break
done

echo "You have selected the following browser: $browser_choice"
echo "You have selected the following package managers: ${package_managers[@]}"
echo "You have selected the following applications: ${applications[@]}"
