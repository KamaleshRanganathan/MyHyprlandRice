#!/bin/bash
# ~/.config/wlogout/switch_theme.sh
# Script to switch between wlogout themes

WLOGOUT_DIR="$HOME/.config/wlogout"
THEMES_DIR="$WLOGOUT_DIR/themes"
CURRENT_THEME_FILE="$WLOGOUT_DIR/.current_theme"

# Function to display available themes
list_themes() {
    echo "Available themes:"
    local i=1
    for theme in "$THEMES_DIR"/*/; do
        theme_name=$(basename "$theme")
        if [ -f "$CURRENT_THEME_FILE" ] && [ "$(cat "$CURRENT_THEME_FILE")" = "$theme_name" ]; then
            echo "  [$i] $theme_name (current)"
        else
            echo "  [$i] $theme_name"
        fi
        ((i++))
    done
}

# Function to apply a theme
apply_theme() {
    local theme_name="$1"
    local theme_path="$THEMES_DIR/$theme_name"
    
    if [ ! -d "$theme_path" ]; then
        echo "Error: Theme '$theme_name' not found!"
        return 1
    fi
    
    # Remove existing symlink or file
    rm -f "$WLOGOUT_DIR/style.css"
    
    # Create symlink to theme's style.css
    ln -sf "$theme_path/style.css" "$WLOGOUT_DIR/style.css"
    
    # If theme has its own layout, link it too
    if [ -f "$theme_path/layout" ]; then
        rm -f "$WLOGOUT_DIR/layout"
        ln -sf "$theme_path/layout" "$WLOGOUT_DIR/layout"
    fi
    
    # Save current theme
    echo "$theme_name" > "$CURRENT_THEME_FILE"
    
    echo "✓ Applied theme: $theme_name"
    
    # Optional: Send notification
    if command -v notify-send &> /dev/null; then
        notify-send "Wlogout Theme" "Switched to $theme_name" -t 2000
    fi
}

# Function to cycle to next theme
next_theme() {
    local themes=()
    for theme in "$THEMES_DIR"/*/; do
        themes+=("$(basename "$theme")")
    done
    
    local current=""
    if [ -f "$CURRENT_THEME_FILE" ]; then
        current=$(cat "$CURRENT_THEME_FILE")
    fi
    
    local next_index=0
    if [ -n "$current" ]; then
        for i in "${!themes[@]}"; do
            if [ "${themes[$i]}" = "$current" ]; then
                next_index=$(( (i + 1) % ${#themes[@]} ))
                break
            fi
        done
    fi
    
    apply_theme "${themes[$next_index]}"
}

# Function to select theme by number
select_by_number() {
    local num="$1"
    local themes=()
    for theme in "$THEMES_DIR"/*/; do
        themes+=("$(basename "$theme")")
    done
    
    if [ "$num" -lt 1 ] || [ "$num" -gt "${#themes[@]}" ]; then
        echo "Error: Invalid theme number!"
        return 1
    fi
    
    apply_theme "${themes[$((num-1))]}"
}

# Main script logic
case "${1:-}" in
    -l|--list)
        list_themes
        ;;
    -n|--next)
        next_theme
        ;;
    -h|--help)
        echo "Usage: switch_theme.sh [OPTIONS] [THEME_NAME]"
        echo ""
        echo "Options:"
        echo "  -l, --list     List all available themes"
        echo "  -n, --next     Switch to next theme"
        echo "  -h, --help     Show this help message"
        echo "  [number]       Select theme by number"
        echo "  [name]         Apply theme by name"
        echo ""
        echo "Examples:"
        echo "  switch_theme.sh style1"
        echo "  switch_theme.sh 2"
        echo "  switch_theme.sh --next"
        ;;
    [0-9]*)
        select_by_number "$1"
        ;;
    "")
        list_themes
        echo ""
        read -p "Enter theme name or number: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            select_by_number "$choice"
        else
            apply_theme "$choice"
        fi
        ;;
    *)
        apply_theme "$1"
        ;;
esac