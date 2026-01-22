#!/bin/sh
# update login screen

set -eu

usage() {
	echo "Usage: $0 /path/to/image.jpg"
	exit 2
}

IMG=${1:-}
if [ -z "$IMG" ]; then
	usage
fi

if [ ! -f "$IMG" ]; then
	echo "Error: image not found: $IMG" >&2
	exit 1
fi

THEME_DIR=/var/lib/sddm/themes
BREEZE_DIR="$THEME_DIR/breeze"
IMG_BASENAME=$(basename "$IMG")

# 1. Create a writable SDDM theme directory
sudo mkdir -p "$THEME_DIR"
sudo cp -r /usr/share/sddm/themes/* "$THEME_DIR/" || true
sudo chown -R sddm:sddm "$THEME_DIR"

# 2. Configure SDDM to use the writable theme directory
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/local-themes.conf > /dev/null <<'EOF'
[Theme]
ThemeDir=/var/lib/sddm/themes
EOF

# Ensure breeze directory exists
if [ ! -d "$BREEZE_DIR" ]; then
	echo "Warning: breeze theme dir not found at $BREEZE_DIR" >&2
	sudo mkdir -p "$BREEZE_DIR"
	sudo chown sddm:sddm "$BREEZE_DIR"
fi

# 3. Copy the wallpaper to the Breeze theme directory
sudo cp "$IMG" "$BREEZE_DIR/"
sudo chown sddm:sddm "$BREEZE_DIR/$IMG_BASENAME" || true

# 4. Edit the Breeze theme config to use the wallpaper
sudo tee /var/lib/sddm/themes/breeze/theme.conf.user > /dev/null <<'EOF'
[General]
type=image
background=$IMG_BASENAME
EOF

# 5. Ensure SDDM uses the Breeze theme
sudo tee -a /etc/sddm.conf.d/local-themes.conf > /dev/null <<'EOF'
Current=breeze
EOF

# 6. Apply changes (this will log you out)
echo "Warning: this will restart SDDM and log you out. Save your work."
read -r -p "Press Enter to restart SDDM or Ctrl-C to cancel..." _
sudo systemctl restart sddm