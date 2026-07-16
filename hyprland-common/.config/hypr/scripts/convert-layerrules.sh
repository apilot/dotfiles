#!/bin/bash

# Hyprland Layer Rules Syntax Converter
# Converts old layerrule syntax to new Hyprland 0.40+ format
# Usage: ./convert-layerrules.sh [hyprland.conf]

set -e

CONFIG_FILE="${1:-hyprland.conf}"
BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
OUTPUT_FILE="${CONFIG_FILE}.layerrules_fixed"

echo "🔧 Hyprland Layer Rules Syntax Converter"
echo "========================================="
echo "Config file: $CONFIG_FILE"
echo ""

# Check if file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Error: File '$CONFIG_FILE' not found!"
    exit 1
fi

# Create backup
echo "📦 Creating backup: $BACKUP_FILE"
cp "$CONFIG_FILE" "$BACKUP_FILE"

# Function to convert a single layerrule line
convert_layerrule() {
    local line="$1"

    # Skip lines that are not layerrules
    if [[ ! "$line" =~ ^layerrule[[:space:]]*= ]]; then
        echo "$line"
        return
    fi

    # Skip lines that already use new syntax (have match:)
    if [[ "$line" =~ match: ]]; then
        echo "$line"
        return
    fi

    # Skip commented lines
    if [[ "$line" =~ ^[[:space:]]*# ]]; then
        echo "$line"
        return
    fi

    # Remove leading/trailing whitespace
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Extract the part after "layerrule = "
    rule_content=$(echo "$line" | sed 's/^layerrule[[:space:]]*=[[:space:]]*//')

    # Parse the rule content
    local current=""
    local in_quotes=false
    local parts=()

    for (( i=0; i<${#rule_content}; i++ )); do
        char="${rule_content:$i:1}"

        if [[ "$char" == "'" || "$char" == '"' ]]; then
            in_quotes=$((!in_quotes))
            current+="$char"
        elif [[ "$char" == ',' && "$in_quotes" == "false" ]]; then
            parts+=("$current")
            current=""
        else
            current+="$char"
        fi
    done

    # Add the last part
    if [[ -n "$current" ]]; then
        parts+=("$current")
    fi

    # Initialize arrays for effects and props
    local effects=()
    local props=()

    for part in "${parts[@]}"; do
        # Trim whitespace
        part=$(echo "$part" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # Skip empty parts
        [[ -z "$part" ]] && continue

        # Check if it's a namespace (the last part usually)
        # Common namespaces: launcher, waybar, caelestia-*, etc.
        if [[ "$part" =~ ^(launcher|waybar|gtk-layer-shell|selection|caelestia) ]] || \
           [[ "$part" =~ ^caelestia- ]] || \
           [[ "$part" =~ ^.*\(.*\) ]]; then
            props+=("match:namespace $part")
        else
            # It's an effect
            # Convert old effect names if needed
            case "$part" in
                noanim)
                    effects+=("no_anim on")
                    ;;
                blurpopups)
                    effects+=("blur_popups on")
                    ;;
                ignorealpha)
                    effects+=("ignore_alpha 0")
                    ;;
                ignorezero)
                    effects+=("ignore_zero 0")
                    ;;
                xray)
                    # Check if it has a value
                    if [[ "$part" =~ xray[[:space:]]+[0-9] ]]; then
                        effects+=("$part")
                    else
                        effects+=("xray on")
                    fi
                    ;;
                blur|noanim|animation|order|dim_around|ignore_alpha|xray|no_screen_share)
                    # These effects might or might not have "on"
                    if [[ "$part" =~ ^[a-z_]+$ ]]; then
                        effects+=("$part on")
                    else
                        effects+=("$part")
                    fi
                    ;;
                *)
                    effects+=("$part")
                    ;;
            esac
        fi
    done

    # Build the new rule
    local new_rule="layerrule = "

    # Add effects
    if [ ${#effects[@]} -gt 0 ]; then
        local first=true
        for effect in "${effects[@]}"; do
            if [ "$first" = true ]; then
                new_rule+="$effect"
                first=false
            else
                new_rule+=", $effect"
            fi
        done
    fi

    # Add props
    if [ ${#props[@]} -gt 0 ]; then
        if [ ${#effects[@]} -gt 0 ]; then
            new_rule+=", "
        fi
        local first=true
        for prop in "${props[@]}"; do
            if [ "$first" = true ]; then
                new_rule+="$prop"
                first=false
            else
                new_rule+=", $prop"
            fi
        done
    fi

    echo "$new_rule"
}

# Process the file line by line
echo "🔄 Converting layerrules..."
line_num=0
converted_count=0
skipped_count=0

while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))

    if [[ "$line" =~ ^layerrule[[:space:]]*= ]] && [[ ! "$line" =~ match: ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
        # Convert the line
        converted_line=$(convert_layerrule "$line")
        echo "$converted_line" >> "$OUTPUT_FILE.tmp"
        converted_count=$((converted_count + 1))

        # Show conversion
        echo "  Line $line_num:"
        echo "    OLD: $line"
        echo "    NEW: $converted_line"
        echo ""
    else
        echo "$line" >> "$OUTPUT_FILE.tmp"
        if [[ "$line" =~ ^layerrule[[:space:]]*= ]] && [[ "$line" =~ match: ]]; then
            skipped_count=$((skipped_count + 1))
        fi
    fi
done < "$CONFIG_FILE"

# Move temp file to output
mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"

# Summary
echo ""
echo "✅ Conversion complete!"
echo "   Converted: $converted_count layerrules"
echo "   Skipped (already new syntax): $skipped_count layerrules"
echo ""
echo "📁 Files created:"
echo "   Backup: $BACKUP_FILE"
echo "   Converted: $OUTPUT_FILE"
echo ""
echo "✋ To apply changes:"
echo "   cp $OUTPUT_FILE $CONFIG_FILE"
echo "   hyprctl reload"
echo ""
