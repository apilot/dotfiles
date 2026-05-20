#!/bin/bash

# Optimize windowrules by removing unnecessary 'on' from boolean effects
# Based on Hyprland documentation, 'on' is optional for many effects

CONFIG_FILE="${1:-hyprland.conf}"
BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
OUTPUT_FILE="${CONFIG_FILE}.optimized"

echo "🔧 Optimizing Hyprland Window Rules"
echo "===================================="
echo ""

# Create backup
cp "$CONFIG_FILE" "$BACKUP_FILE"

# Process the file
echo "🔄 Optimizing windowrules..."
converted_count=0

while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^windowrule[[:space:]]*= ]]; then
        # Remove unnecessary 'on' from effects where it's optional
        # According to docs, these work with or without 'on': float, tile, center, pseudo, pin, maximize, fullscreen
        new_line=$(echo "$line" | sed -E '
            s/float on,/float,/g;
            s/float on$/,float/;
            s/tile on,/tile,/g;
            s/tile on$/,tile/;
            s/center on,/center,/g;
            s/center on$/,center/;
            s/pseudo on,/pseudo,/g;
            s/pseudo on$/,pseudo/;
            s/pin on,/pin,/g;
            s/pin on$/,pin/;
            s/maximize on,/maximize,/g;
            s/maximize on$/,maximize/;
            s/fullscreen on,/fullscreen,/g;
            s/fullscreen on$/,fullscreen/;
        ')

        if [[ "$new_line" != "$line" ]]; then
            converted_count=$((converted_count + 1))
            if [ $converted_count -le 5 ]; then
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

echo "✅ Optimization complete!"
echo "   Optimized: $converted_count rules"
echo ""
echo "📁 Files:"
echo "   Backup: $BACKUP_FILE"
echo "   Optimized: $OUTPUT_FILE"
echo ""
echo "✋ To apply:"
echo "   cp $OUTPUT_FILE $CONFIG_FILE"
echo "   hyprctl reload"
echo ""
