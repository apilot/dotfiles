#!/bin/bash
set -e

echo "🎨 Installing Catppuccin GTK theme with GTK-4 support..."
echo

# 1. Unmask package
echo "📦 Unmasking catppuccin-gtk package..."
sudo bash -c 'cat > /etc/portage/package.accept_keywords/catppuccin << EOF
=x11-themes/catppuccin-gtk-1.0.3::~amd64
EOF'

# 2. Configure USE flags
echo "⚙️  Configuring USE flags (mocha only)..."
sudo bash -c 'cat > /etc/portage/package.use/catppuccin << EOF
x11-themes/catppuccin-gtk mocha -frappe -latte -macchiato
EOF'

# 3. Install package
echo "📥 Installing x11-themes/catppuccin-gtk..."
sudo emerge x11-themes/catppuccin-gtk

echo
echo "✅ Package installed successfully!"
echo

# 4. Backup current GTK-4 settings
echo "💾 Backing up current GTK-4 settings..."
mkdir -p ~/.config/gtk-4.0
if [ -f ~/.config/gtk-4.0/settings.ini ]; then
    cp ~/.config/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini.backup.$(date +%Y%m%d_%H%M%S)
fi

# 5. Update GTK-4 settings
echo "🔧 Configuring GTK-4 to use Catppuccin theme..."
cat > ~/.config/gtk-4.0/settings.ini << 'EOF'
[Settings]
gtk-application-prefer-dark-theme=true
gtk-cursor-theme-name=catppuccin-mocha-dark-cursors
gtk-cursor-theme-size=24
gtk-decoration-layout=icon:minimize,maximize,close
gtk-enable-animations=true
gtk-font-name=Noto Sans,  10
gtk-icon-theme-name=Infinity-Lavender-Dark-Icons
gtk-modules=colorreload-gtk-module
gtk-primary-button-warps-slider=true
gtk-sound-theme-name=ocean
gtk-xft-dpi=98304
gtk-theme-name=catppuccin-mocha-lavender-standard+default
EOF

echo
echo "✅ GTK-4 configured successfully!"
echo

# 6. Verify Kvantum theme
echo "🎭 Verifying Kvantum theme..."
mkdir -p ~/.config/Kvantum
cat > ~/.config/Kvantum/kvantum.kvconfig << EOF
[General]
theme=Catppuccin-Mocha-Lavender
EOF

echo
echo "🎉 Installation complete!"
echo
echo "📋 Summary:"
echo "  - GTK-3 theme: Catppuccin-Mocha-Standard-Lavender-Dark"
echo "  - GTK-4 theme: catppuccin-mocha-lavender-standard+default"
echo "  - QT theme: Kvantum (Catppuccin-Mocha-Lavender)"
echo
echo "⚠️  To apply changes:"
echo "  1. Restart GTK applications (like GNOME Calendar)"
echo "  2. Or logout and login again"
echo "  3. Or reboot the system"
echo
echo "🔍 To verify:"
echo "  - GTK-3: cat ~/.config/gtk-3.0/settings.ini"
echo "  - GTK-4: cat ~/.config/gtk-4.0/settings.ini"
echo "  - QT:    cat ~/.config/qt6ct/qt6ct.conf"
echo "  - Kvantum: kvantummanager"
