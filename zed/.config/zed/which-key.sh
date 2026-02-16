#!/bin/bash
# Which-key style menu for Zed Editor
# Shows available keybindings in a popup (similar to nvim which-key)

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print section header
print_section() {
    echo -e "\n${CYAN}${BOLD}═══ $1 ═══${NC}"
}

# Function to print keybinding
print_binding() {
    local key="$1"
    local desc="$2"
    printf "  ${BOLD}${GREEN}%-20s${NC} %s\n" "$key" "$desc"
}

# Function to print subsection
print_subsection() {
    echo -e "\n${YELLOW}▸ $1${NC}"
}

clear
echo -e "${BOLD}${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   Zed Editor - Which-Key Reference                        ║
║   (Neovim LazyVim Style)                                  ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_section "LEADER: Space"
echo "Most frequently used keybindings:"

print_subsection "Quick Actions"
print_binding "Space w" "Save file"
print_binding "Space q" "Close file"
print_binding "Space Q" "Quit Zed"
print_binding "Space e" "File explorer"

print_subsection "Files (leader+f)"
print_binding "Space ff / Space Space" "Find files"
print_binding "Space fg" "Live grep (ripgrep)"
print_binding "Space fr" "Recent files"
print_binding "Space fb" "Buffers"

print_subsection "Git (leader+g)"
print_binding "Space gg" "LazyGit"
print_binding "Space gs" "Git status"
print_binding "Space gc" "Git commit"
print_binding "Space gp" "Git push"

print_subsection "LSP (leader+l)"
print_binding "Space lf" "Format code"
print_binding "Space ld" "Go to definition"
print_binding "Space li" "Go to implementation"
print_binding "Space lr" "Find references"
print_binding "Space ln" "Rename symbol"
print_binding "Space la" "Code actions"

print_subsection "Windows (leader+w)"
print_binding "Space we" "Equalize windows"
print_binding "Space wv" "Split vertical"
print_binding "Space wh" "Split horizontal"
print_binding "Space wq" "Close window"

print_subsection "Navigation (Ctrl+hjkl)"
print_binding "Ctrl+h" "Move to left window"
print_binding "Ctrl+j" "Move to bottom window"
print_binding "Ctrl+k" "Move to top window"
print_binding "Ctrl+l" "Move to right window"

print_subsection "Terminal (leader+t)"
print_binding "Space tt" "Toggle terminal"

print_subsection "UI Toggles (leader+u)"
print_binding "Space uz" "Zen mode"
print_binding "Space ul" "Toggle left dock"
print_binding "Space ur" "Toggle right dock"
print_binding "Space ub" "Toggle bottom dock"

print_section "VIM MODE"
print_binding "i" "Insert mode"
print_binding "Esc" "Normal mode"
print_binding "dd" "Delete line"
print_binding "yy" "Yank line"
print_binding "p" "Paste"
print_binding "/" "Search"
print_binding "n/N" "Next/previous search result"

print_section "ZED NATIVE"
print_binding "Ctrl+Shift+P" "Command palette"
print_binding "Ctrl+P" "Quick open"
print_binding "Ctrl+Shift+F" "Find in files"
print_binding "Ctrl+B" "Toggle sidebar"
print_binding "Ctrl+`" "Toggle terminal"

echo -e "\n${MAGENTA}Press any key to exit...${NC}"
read -n 1 -s
