#!/bin/bash
# Zed Editor - Neovim LazyVim Configuration Installer
# This script sets up Zed Editor with keybindings and settings ported from Neovim LazyVim

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=====================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check dependencies
check_dependencies() {
    print_header "Checking Dependencies"

    local deps=("rg" "fzf" "bat" "kitty")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        else
            print_success "$dep is installed"
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_info "Please install missing dependencies:"
        echo "  - Gentoo: emerge app-misc/fzf app-text/bat sys-apps/ripgrep x11-terms/kitty"
        echo "  - Ubuntu/Debian: apt install fzf bat ripgrep kitty"
        echo "  - Arch: pacman -S fzf bat ripgrep kitty"
        exit 1
    fi
}

# Backup existing configuration
backup_config() {
    print_header "Backing Up Configuration"

    local config_dir="$HOME/.config/zed"
    local backup_dir="$HOME/.config/zed.backup.$(date +%Y%m%d_%H%M%S)"

    if [ -d "$config_dir" ] && [ ! -L "$config_dir" ]; then
        mkdir -p "$backup_dir"
        cp -r "$config_dir"/* "$backup_dir/" 2>/dev/null || true
        print_success "Configuration backed up to: $backup_dir"
    else
        print_info "No existing configuration to backup (or using symlink)"
    fi
}

# Create symbolic link
create_symlink() {
    print_header "Creating Symlink"

    local source_dir="$HOME/dotfiles/zed/.config/zed"
    local target_dir="$HOME/.config/zed"

    # Remove existing symlink if it exists
    if [ -L "$target_dir" ]; then
        rm "$target_dir"
        print_info "Removed existing symlink"
    fi

    # Create new symlink
    ln -s "$source_dir" "$target_dir"
    print_success "Created symlink: $target_dir -> $source_dir"
}

# Verify configuration
verify_config() {
    print_header "Verifying Configuration"

    local config_dir="$HOME/.config/zed"
    local required_files=("settings.json" "keymap.json" "tasks.json")

    for file in "${required_files[@]}"; do
        if [ -f "$config_dir/$file" ]; then
            print_success "$file exists"
        else
            print_error "$file is missing!"
            return 1
        fi
    done

    # Validate JSON files
    if command -v jq &> /dev/null; then
        for file in "${required_files[@]}"; do
            if jq empty "$config_dir/$file" 2>/dev/null; then
                print_success "$file is valid JSON"
            else
                print_error "$file has invalid JSON!"
                return 1
            fi
        done
    else
        print_info "jq not installed, skipping JSON validation"
    fi
}

# Print summary
print_summary() {
    print_header "Installation Complete!"

    echo
    echo -e "${GREEN}Your Zed Editor has been configured with Neovim LazyVim keybindings!${NC}"
    echo
    echo "📚 Quick Reference:"
    echo "  • Space Space - Find files"
    echo "  • Space f f   - Find files"
    echo "  • Space f g   - Live grep (ripgrep)"
    echo "  • Space g g   - Lazygit"
    echo "  • Space l d   - Go to definition"
    echo "  • Space l f   - Format code"
    echo "  • Space w     - Save file"
    echo "  • Space q     - Close file"
    echo "  • Space t t   - Toggle terminal"
    echo "  • Ctrl+h/j/k/l - Navigate windows"
    echo
    echo "📖 Full reference: $HOME/.config/zed/KEYMAP_REFERENCE.md"
    echo
    echo "🔄 Restart Zed Editor to apply changes"
    echo
}

# Main installation
main() {
    print_header "Zed Editor - Neovim LazyVim Configuration"

    check_dependencies
    backup_config
    create_symlink
    verify_config
    print_summary
}

# Run main function
main "$@"
