#!/bin/bash

# Directory where your themes are stored
THEME_DIR="$HOME/.config/waybar/themes"

# The theme to switch to, passed as an argument
THEME_NAME=$1

# Check if a theme name was provided
if [ -z "$THEME_NAME" ]; then
    echo "Usage: $0 <theme_name>"
    echo "Available themes:"
    ls "$THEME_DIR"
    exit 1
fi

# Check if the theme directory exists
if [ ! -d "$THEME_DIR/$THEME_NAME" ]; then
    echo "Error: Theme '$THEME_NAME' not found."
    echo "Available themes:"
    ls "$THEME_DIR"
    exit 1
fi

# Define the target symlinks
WAYBAR_CONFIG_LINK="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE_LINK="$HOME/.config/waybar/style.css"

# Define the source files for the chosen theme
SOURCE_CONFIG="$THEME_DIR/$THEME_NAME/config.jsonc"
SOURCE_STYLE="$THEME_DIR/$THEME_NAME/style.css"

# Remove existing symlinks if they exist
[ -L "$WAYBAR_CONFIG_LINK" ] && rm "$WAYBAR_CONFIG_LINK"
[ -L "$WAYBAR_STYLE_LINK" ] && rm "$WAYBAR_STYLE_LINK"

# Create new symlinks
ln -s "$SOURCE_CONFIG" "$WAYBAR_CONFIG_LINK"
ln -s "$SOURCE_STYLE" "$WAYBAR_STYLE_LINK"

echo "Switched Waybar theme to '$THEME_NAME'."

# Reload Waybar to apply changes
# Using SIGUSR2 is the recommended way to reload Waybar's style and config
killall -SIGUSR2 waybar

echo "Waybar reloaded."
