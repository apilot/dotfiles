#!/bin/bash

# Fix boolean effects by adding 'on' back where needed
# Hyprland requires values for boolean effects

CONFIG_FILE="${1:-hyprland.conf}"
BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
OUTPUT_FILE="${CONFIG_FILE}.fixed"

echo "🔧 Fixing Boolean Effects in Hyprland Config"
echo "==========================================="
echo ""

# Create backup
cp "$CONFIG_FILE" "$BACKUP_FILE"

# Process the file
echo "🔄 Fixing windowrules..."
fixed_count=0

while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^windowrule[[:space:]]*= ]]; then
        # Fix boolean effects by adding 'on'
        new_line=$(echo "$line" | sed -E '
            s/windowrule = float,/windowrule = float on,/g;
            s/windowrule = tile,/windowrule = tile on,/g;
            s/windowrule = center,/windowrule = center on,/g;
            s/windowrule = pseudo,/windowrule = pseudo on,/g;
            s/windowrule = pin,/windowrule = pin on,/g;
            s/windowrule = maximize,/windowrule = maximize on,/g;
            s/windowrule = fullscreen,/windowrule = fullscreen on,/g;
        ')

        if [[ "$new_line" != "$line" ]]; then
            fixed_count=$((fixed_count + 1))
            if [ $fixed_count -le 5 ]; then
                echo "  $line"
                echo "  → $new_line"
                echo ""
            fi
        fi

        echo "$new_line" >> "$OUTPUT_FILE.tmp"
    else
        echo "$line" >> "$OUTPUT_FILE.tmp"
    fi
done < "$CONFIG_FILE"

mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"

echo "✅ Fixed $fixed_count rules!"
echo ""
echo "📁 Files:"
echo "   Backup: $BACKUP_FILE"
echo "   Fixed: $OUTPUT_FILE"
echo ""
echo "✋ To apply:"
echo "   cp $OUTPUT_FILE $CONFIG_FILE"
echo "   hyprctl reload"
echo ""
