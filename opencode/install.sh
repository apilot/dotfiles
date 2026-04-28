#!/usr/bin/env bash
# OpenCode config installer — deploys configs from dotfiles via stow,
# installs npm dependencies, builds MCP Excalidraw, checks env vars.
set -euo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $*"; }

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
OPENCODE_DIR="$DOTFILES/opencode"
CONFIG_SRC="$OPENCODE_DIR/.config/opencode"
CONFIG_DST="$HOME/.config/opencode"

# --- Step 1: Check dependencies ---
info "Checking dependencies..."

check_cmd() {
  if command -v "$1" &>/dev/null; then
    ok "$1 found ($(command -v "$1"))"
    return 0
  else
    fail "$1 not found"
    return 1
  fi
}

DEPS_OK=true
for cmd in node npm npx stow; do
  check_cmd "$cmd" || DEPS_OK=false
done

if [[ "$DEPS_OK" == false ]]; then
  fail "Missing required dependencies. Install them and re-run."
  exit 1
fi

# --- Step 2: Prepare stow structure ---
info "Preparing dotfiles stow structure..."

if [[ ! -d "$CONFIG_SRC" ]]; then
  info "Creating .config/opencode/ in dotfiles..."
  mkdir -p "$CONFIG_SRC"

  # Copy current live config into dotfiles (first-time setup)
  if [[ -d "$CONFIG_DST" ]]; then
    info "Syncing live config from $CONFIG_DST to dotfiles..."
    # Use rsync if available, fallback to cp
    if command -v rsync &>/dev/null; then
      rsync -a --exclude='node_modules' --exclude='.git' --exclude='dist' --exclude='*.log' "$CONFIG_DST/" "$CONFIG_SRC/"
    else
      # Copy everything except excluded dirs
      cp -r "$CONFIG_DST"/* "$CONFIG_SRC/" 2>/dev/null || true
      cp "$CONFIG_DST"/.gitignore "$CONFIG_SRC/" 2>/dev/null || true
    fi
    ok "Config synced to dotfiles"
  else
    fail "No existing opencode config at $CONFIG_DST to bootstrap from"
    exit 1
  fi
else
  ok "Stow source already exists at $CONFIG_SRC"
fi

# --- Step 3: Stow (symlink) configs ---
info "Deploying configs via stow..."

# Remove existing live config if it's not already a symlink
if [[ -d "$CONFIG_DST" && ! -L "$CONFIG_DST" ]]; then
  warn "$CONFIG_DST exists as a real directory"
  read -rp "Remove it and replace with stow symlink? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$CONFIG_DST"
  else
    info "Skipping stow. Files will need manual sync."
    SKIP_STOW=true
  fi
fi

if [[ "${SKIP_STOW:-false}" != true ]]; then
  (cd "$OPENCODE_DIR" && stow -t "$HOME" -R . 2>/dev/null && ok "Stow linked successfully") \
    || warn "Stow had issues (may already be linked)"
fi

# --- Step 4: Fix hardcoded paths ---
info "Fixing hardcoded paths in opencode.json..."

if [[ -f "$CONFIG_DST/opencode.json" ]]; then
  # Replace hardcoded /home/username with $HOME
  if grep -q "/home/[a-zA-Z0-9_]*/" "$CONFIG_DST/opencode.json" 2>/dev/null; then
    sed -i "s|/home/[a-zA-Z0-9_]*|.config/opencode|g" "$CONFIG_DST/opencode.json"
    # Actually we need the full path with $HOME
    sed -i "s|.config/opencode/.config/opencode|$HOME/.config/opencode|g" "$CONFIG_DST/opencode.json"
    ok "Paths fixed to use current HOME ($HOME)"
  else
    ok "No hardcoded paths found (already portable)"
  fi
fi

# --- Step 5: Verify target exists ---
if [[ ! -d "$CONFIG_DST" ]]; then
  fail "$CONFIG_DST does not exist after stow. Check stow output above."
  exit 1
fi

# --- Step 6: Install npm dependencies ---
info "Installing root npm dependencies..."
(
  cd "$CONFIG_DST"
  if [[ -f package.json ]]; then
    npm install --silent 2>/dev/null && ok "Root dependencies installed" || warn "Root npm install had issues"
  else
    info "No package.json found, skipping root npm install"
  fi
)

# --- Step 7: Build MCP Excalidraw ---
info "Setting up MCP Excalidraw..."
EXCALIDRAW_DIR="$CONFIG_DST/mcp/mcp_excalidraw"

if [[ -d "$EXCALIDRAW_DIR" ]]; then
  (
    cd "$EXCALIDRAW_DIR"
    if [[ -f package.json ]]; then
      info "Installing excalidraw npm dependencies..."
      npm install --silent 2>/dev/null || warn "npm install had issues"

      if [[ ! -d dist ]]; then
        info "Building excalidraw (frontend + server)..."
        npm run build 2>/dev/null && ok "MCP Excalidraw built" || warn "Build had issues — try manually: cd $EXCALIDRAW_DIR && npm run build"
      else
        ok "MCP Excalidraw already built (dist/ exists)"
      fi
    fi
  )
else
  warn "MCP Excalidraw not found at $EXCALIDRAW_DIR"
fi

# --- Step 8: Check global npm packages ---
info "Checking global npm packages..."

check_global_npm() {
  local pkg="$1"
  if npm list -g "$pkg" &>/dev/null; then
    ok "$pkg installed globally"
  else
    warn "$pkg not found globally — install with: npm i -g $pkg"
  fi
}

check_global_npm "@z_ai/mcp-server"

# --- Step 9: Check Ruby gem (hwc-mcp) ---
info "Checking hwc-mcp gem..."
if command -v gem &>/dev/null; then
  if gem list -i hwc-mcp &>/dev/null; then
    ok "hwc-mcp gem installed"
  else
    warn "hwc-mcp gem not found — install with: gem install hwc-mcp"
  fi
else
  warn "ruby/gem not found — hwc-mcp MCP server won't work"
fi

# --- Step 10: Check environment variables ---
info "Checking required environment variables..."

ENV_VARS=(
  "Z_AI_API_KEY:Required for provider and most MCP servers"
  "CONTEXT7_API_KEY:Required for context7 MCP server"
  "GEMINI_API_KEY:Optional — for Gemini image tool"
  "MINIMAX_API_KEY:Optional — for MiniMax image tool"
)

ENV_MISSING=false
for entry in "${ENV_VARS[@]}"; do
  var="${entry%%:*}"
  desc="${entry#*:}"
  if [[ -n "${!var:-}" ]]; then
    ok "$var is set"
  else
    warn "$var is NOT set — $desc"
    ENV_MISSING=true
  fi
done

if [[ "$ENV_MISSING" == true ]]; then
  info "Add missing keys to your shell profile or .env file"
fi

# --- Done ---
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  OpenCode setup complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
info "Config location: $CONFIG_DST"
info "Run 'opencode' to start"
