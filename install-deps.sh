#!/bin/bash

# Media & Audio
media_packages=(
    cava pavucontrol playerctl songrec wf-recorder
)

# Fonts & Emoji
fonts_packages=(
    noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd
)

# Hyprland & Daily Utilities Group
system_packages=(
    libdbusmenu-gtk3 geoclue brightnessctl ddcutil bc cliphist ripgrep jq
    xdg-user-dirs eza ghostty fontconfig matugen quickshell
    tesseract-data-eng wtype ydotool fuzzel glib2 imagemagick
    translate-shell libqalculate
    
    hyprland hyprsunset bluedevil gnome-keyring hyprshot
    hypridle hyprlock hyprpicker adw-gtk-theme
)

# Qt Libraries & Supporting Components Group
qt_packages=(
    qt6-base qt6-declarative qt6-5compat qt6-imageformats qt6-multimedia
    qt6-positioning qt6-quicktimeline qt6-sensors qt6-svg qt6-tools
    qt6-translations qt6-virtualkeyboard qt6-wayland
)

# Development & System Libraries
devel_packages=(
    kirigami kdialog syntax-highlighting vulkan-headers libdrm
    cpptrace jemalloc mesa
)

echo "=== Starting Dependency Check & Installation ==="
to_install=()

check_packages() {
    local category_name="$1"
    shift
    local pkgs=("$@")
    
    echo -e "\n--- Checking: $category_name ---"
    for pkg in "${pkgs[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            echo "[SKIP] Package '$pkg' is already installed."
        else
            echo "[QUEUE] Package '$pkg' is missing."
            to_install+=("$pkg")
        fi
    done
}

# Run checks
check_packages "Media & Audio" "${media_packages[@]}"
check_packages "Fonts" "${fonts_packages[@]}"
check_packages "Hyprland & Daily Utilities Group" "${system_packages[@]}"
check_packages "Qt" "${qt_packages[@]}"
check_packages "Development & System Libraries" "${devel_packages[@]}"

# Execute package installation
if [ ${#to_install[@]} -eq 0 ]; then
    echo -e "\nYay! All main packages are already installed! (⁄ ⁄>⁄ ▽ ⁄<⁄ ⁄)"
else
    echo -e "\nInstalling total ${#to_install[@]} missing packages..."
    sudo pacman -S --needed "${to_install[@]}"
fi

    echo -e "\nInstalling others packages"

# ==========================================
# Breeze Plus Icons
# ==========================================
read -p "Do you want to install Breeze Plus Icons? (y/n): " install_icons
if [[ "$install_icons" =~ ^[Yy]$ ]]; then
    echo "--- Installing Breeze Plus Icons ---"
    git clone https://github.com/mjkim0727/breeze-plus.git
    cd breeze-plus/src
    cp -r breeze-plus* ~/.local/share/icons/
    cd ../../
    rm -rf breeze-plus
    echo -e "Breeze Plus Icons successfully installed! (⁄ ⁄>⁄ ▽ ⁄<⁄ ⁄)"
fi

# ==========================================
# SDDM Astronaut Theme
# ==========================================
read -p "Do you want to install SDDM Astronaut Theme? (y/n): " install_sddm
if [[ "$install_sddm" =~ ^[Yy]$ ]]; then
    echo "--- Installing SDDM Astronaut Theme ---"
    sudo git clone -b master --depth 1 https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme
    sudo cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
    
    echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee /etc/sddm.conf
    echo -e "[General]\nInputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf 
    echo -e "SDDM Astronaut Theme setup completed! (⁄ ⁄>⁄ ▽ ⁄<⁄ ⁄)"
fi

# ==========================================
# AUR Helper (yay)
# ==========================================
read -p "Do you want to install AUR helper (yay)? (y/n): " install_yay
if [[ "$install_yay" =~ ^[Yy]$ ]]; then
    echo "--- Installing yay AUR Helper ---"
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
    echo -e "Yay successfully installed! (⁄ ⁄>⁄ ▽ ⁄<⁄ ⁄)"
fi

echo -e "\nAll processes finished! (⁄ ⁄•⁄ω⁄•⁄ ⁄)⁄"
