# Variables
declare -A packages=(
    # Applications
    ["Librewolf"]=false
    ["Jetbrains Toolbox"]=false
    ["Discord"]=false
    ["Steam"]=false
    ["Thunderbird"]=false
    ["Spotify"]=false
    ["OBS"]=false
    ["GNOME Boxes"]=false

    # Devtools
    ["Temurin 21"]=false
    ["Clang"]=false
    ["PKG Config"]=false
    ["Lua 5.4"]=false
    ["Fast Node Manager"]=false
    ["Zig"]=false
)

order=("Librewolf" "Jetbrains Toolbox" "Discord" "Steam" "Thunderbird" "Spotify" "OBS" "GNOME Boxes"
    "Temurin 21" "Clang" "PKG Config" "Lua 5.4" "Fast Node Manager" "Zig")

error_count=0
declare -A error_log

# Utility Functions
print_progress() {
    local message="$1"
    local depth="$2"

    for ((i = 0; i < depth - 1; i++)); do
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

    for ((i = 0; i < depth - 1; i++)); do
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

ask_install() {
    local package="$1"
    echo "Do you want to install $package? (y/n)"
    read -r response
    if [[ "$response" = [Yy] ]]; then
        packages["$package"]=true
    fi
}

install_package() {
    local pkg_name="$1"
    local install_cmd="$2"
    print_progress "Installing $pkg_name" 2
    error_output=$(eval "$install_cmd" 2>&1 >/dev/null)
    if [ $? -eq 0 ]; then
        print_result true "$pkg_name installed" 2
    else
        print_result false "$pkg_name installation failed" 2 "$error_output"
    fi
}