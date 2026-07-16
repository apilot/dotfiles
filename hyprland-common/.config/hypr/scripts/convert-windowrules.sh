#!/bin/bash

# Hyprland Window Rules Syntax Converter
# Converts old windowrule syntax to new Hyprland 0.40+ format
# Usage: ./convert-windowrules.sh [hyprland.conf]

set -e

CONFIG_FILE="${1:-hyprland.conf}"
BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
OUTPUT_FILE="${CONFIG_FILE}.converted"

echo "🔧 Hyprland Window Rules Syntax Converter"
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

# Create temporary file for processing
TEMP_FILE=$(mktemp)

# Function to convert a single windowrule line
convert_windowrule() {
    local line="$1"

    # Skip lines that are not windowrules
    if [[ ! "$line" =~ ^windowrule[[:space:]]*= ]]; then
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

    # Remove leading/trailing whitespace but preserve inner structure
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Extract the part after "windowrule = "
    rule_content=$(echo "$line" | sed 's/^windowrule[[:space:]]*=[[:space:]]*//')

    # Parse the rule content manually since we need to preserve spaces in values
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

        # Check if it's a property (contains : but not :// or similar)
        if [[ "$part" =~ ^[a-zA-Z_]+:[^/] ]]; then
            prop_name=$(echo "$part" | cut -d':' -f1)
            prop_value=$(echo "$part" | cut -d':' -f2-)

            case "$prop_name" in
                title)
                    props+=("match:title $prop_value")
                    ;;
                class)
                    props+=("match:class $prop_value")
                    ;;
                initialTitle)
                    props+=("match:initial_title $prop_value")
                    ;;
                initialClass)
                    props+=("match:initial_class $prop_value")
                    ;;
                xwayland)
                    props+=("match:xwayland $prop_value")
                    ;;
                floating)
                    props+=("match:float $prop_value")
                    ;;
                workspace)
                    props+=("match:workspace $prop_value")
                    ;;
                *)
                    # Unknown property, keep as is with match:
                    props+=("match:$prop_name $prop_value")
                    ;;
            esac
        else
            # It's an effect
            # Convert old effect names to new ones
            case "$part" in
                noanim|noanimation)
                    effects+=("no_anim on")
                    ;;
                noblur)
                    effects+=("no_blur on")
                    ;;
                nodim)
                    effects+=("no_dim on")
                    ;;
                noshadow)
                    effects+=("no_shadow on")
                    ;;
                nofocus)
                    effects+=("no_focus on")
                    ;;
                stayfocused)
                    effects+=("stay_focused on")
                    ;;
                keepaspectratio)
                    effects+=("keep_aspect_ratio on")
                    ;;
                float|tile|fullscreen|maximize|pin|pseudo|center)
                    effects+=("$part on")
                    ;;
                *)
                    # Check if it's a boolean effect without value
                    if [[ "$part" =~ ^[a-z_]+$ ]]; then
                        effects+=("$part on")
                    else
                        effects+=("$part")
                    fi
                    ;;
            esac
        fi
    done

    # Build the new rule
    # Format: windowrule = EFFECT1, EFFECT2..., match:PROP1 VALUE1, match:PROP2 VALUE2...
    local new_rule="windowrule = "

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
echo "🔄 Converting windowrules..."
line_num=0
converted_count=0
skipped_count=0

while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))

    if [[ "$line" =~ ^windowrule[[:space:]]*= ]] && [[ ! "$line" =~ match: ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
        # Convert the line
        converted_line=$(convert_windowrule "$line")
        echo "$converted_line" >> "$TEMP_FILE"
        converted_count=$((converted_count + 1))

        # Show conversion for first few lines
        if [ $converted_count -le 5 ]; then
            echo "  Line $line_num:"
            echo "    OLD: $line"
            echo "    NEW: $converted_line"
            echo ""
        fi
    else
        echo "$line" >> "$TEMP_FILE"
        if [[ "$line" =~ ^windowrule[[:space:]]*= ]] && [[ "$line" =~ match: ]]; then
            skipped_count=$((skipped_count + 1))
        fi
    fi
done < "$CONFIG_FILE"

# Move temp file to output
mv "$TEMP_FILE" "$OUTPUT_FILE"

# Summary
echo ""
echo "✅ Conversion complete!"
echo "   Converted: $converted_count rules"
echo "   Skipped (already new syntax): $skipped_count rules"
echo ""
echo "📁 Files created:"
echo "   Backup: $BACKUP_FILE"
echo "   Converted: $OUTPUT_FILE"
echo ""
echo "🔍 To review changes:"
echo "   diff $CONFIG_FILE $OUTPUT_FILE | less"
echo ""
echo "✋ To apply changes:"
echo "   cp $OUTPUT_FILE $CONFIG_FILE"
echo "   hyprctl reload"
echo ""
echo "⚠️  Test the new configuration before removing the backup!"
echo "   If something goes wrong, restore with:"
echo "   cp $BACKUP_FILE $CONFIG_FILE"
