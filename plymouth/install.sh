#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "This ritual requires root privileges. Invoke with 'sudo'."
    exit 1
fi

PLYMOUTH_THEMES_DIR="/usr/share/plymouth/themes"
THEME_SOURCE_DIR="./simple-image"

# Extract the theme's true name from its directory.
THEME_NAME=$(basename "$THEME_SOURCE_DIR")
THEME_DEST_DIR="$PLYMOUTH_THEMES_DIR/$THEME_NAME"
PLYMOUTH_FILE=""

# Seek the `.plymouth` manifestation within the directory.
for file in "$THEME_SOURCE_DIR"/*.plymouth; do
    if [ -f "$file" ]; then
        PLYMOUTH_FILE=$(basename "$file")
        break
    fi
done

if [ -z "$PLYMOUTH_FILE" ]; then
    echo "Error: No '.plymouth' file found in '$THEME_SOURCE_DIR'. This theme is incomplete. Verify its structure."
    exit 1
fi

echo "Initiating installation for theme: '$THEME_NAME'"
echo "Copying files from '$THEME_SOURCE_DIR' to '$THEME_DEST_DIR'..."

# Create the destination and copy the files.
mkdir -p "$THEME_DEST_DIR" || { echo "Failed to create destination directory. Permissions, perhaps?"; exit 1; }
cp -R "$THEME_SOURCE_DIR"/* "$THEME_DEST_DIR/" || { echo "Failed to copy theme files. The spirits of the filesystem resist."; exit 1; }

echo "Registering the new theme with the system's alternatives..."
# Register the theme. A higher priority (e.g., 100) often ensures it's chosen.
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth "$THEME_DEST_DIR/$PLYMOUTH_FILE" 100 || { echo "Failed to register theme. Is 'update-alternatives' missing? Or is this distribution too traditional?"; exit 1; }

echo "Setting '$THEME_NAME' as the default boot theme. Let its dark glory illuminate your startup!"
# Set it as the default.
update-alternatives --set default.plymouth "$THEME_DEST_DIR/$PLYMOUTH_FILE" || { echo "Failed to set default theme. Is something already set in stone?"; exit 1; }

echo "Updating the initramfs. This embeds the theme into your boot sequence. Patience, young padawan."
# Update the initramfs to make the changes effective on boot.
update-initramfs -u || { echo "Failed to update initramfs. Your system resists change. Investigate."; exit 1; }

echo ""
echo "Installation complete. For the change to manifest, a ceremonial reboot is required."
echo "Go forth, and witness the transformation!"
echo ""
echo "Disclaimer: If your system doesn't boot, blame cosmic alignment, not this script. (But seriously, check dmesg and system logs)."