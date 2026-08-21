#!/usr/bin/env bash
# OpenCode config installer — deploys configs from dotfiles via stow,
# initializes the mcp_excalidraw submodule, creates the RLM venv,
# installs npm dependencies, and checks env vars.
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
EXCALIDRAW_DIR="$CONFIG_SRC/mcp/mcp_excalidraw"
RLM_DIR="$CONFIG_SRC/mcp/rlm"

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
for cmd in node npm npx stow git; do
  check_cmd "$cmd" || DEPS_OK=false
done
command -v python3 &>/dev/null && ok "python3 found" || { fail "python3 not found"; DEPS_OK=false; }

if [[ "$DEPS_OK" == false ]]; then
  fail "Missing required dependencies. Install them and re-run."
  exit 1
fi

# --- Step 2: Verify stow source exists ---
if [[ ! -d "$CONFIG_SRC" ]]; then
  fail "Stow source $CONFIG_SRC not found in dotfiles."
  exit 1
fi
ok "Stow source exists at $CONFIG_SRC"

# --- Step 3: Stow (symlink) configs ---
info "Deploying configs via stow..."

# Remove existing live config if it's not already a symlink to our package
if [[ -e "$CONFIG_DST" && ! -L "$CONFIG_DST" ]]; then
  warn "$CONFIG_DST exists and is not a symlink"
  read -rp "Remove it and replace with stow symlink? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$CONFIG_DST"
  else
    fail "Cannot stow over existing directory. Aborting."
    exit 1
  fi
fi

# --ignore keeps install.sh (and this script itself) out of $HOME
(cd "$OPENCODE_DIR" && stow -t "$HOME" -R . --ignore='install\.sh' --ignore='backup') \
  && ok "Stow linked successfully" \
  || fail "Stow failed"

if [[ ! -d "$CONFIG_DST" ]]; then
  fail "$CONFIG_DST does not exist after stow. Check stow output above."
  exit 1
fi

# --- Step 4: Init git submodule (mcp_excalidraw) ---
info "Initializing mcp_excalidraw submodule..."
if git -C "$DOTFILES" submodule status -- opencode/.config/opencode/mcp/mcp_excalidraw 2>/dev/null | grep -q '^-'; then
  git -C "$DOTFILES" submodule update --init -- opencode/.config/opencode/mcp/mcp_excalidraw \
    && ok "Submodule initialized" \
    || warn "Submodule init failed — run: git -C $DOTFILES submodule update --init"
else
  ok "Submodule already initialized"
fi

# --- Step 5: Install root npm dependencies ---
info "Installing root npm dependencies..."
(
  cd "$CONFIG_DST"
  if [[ -f package.json ]]; then
    npm install --silent 2>/dev/null && ok "Root dependencies installed" || warn "Root npm install had issues"
  else
    info "No package.json found, skipping root npm install"
  fi
)

# --- Step 6: Build MCP Excalidraw ---
info "Setting up MCP Excalidraw..."

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

# --- Step 7: Create RLM venv ---
info "Setting up RLM MCP server..."

if [[ -d "$RLM_DIR" && -f "$RLM_DIR/server.py" ]]; then
  if [[ -x "$RLM_DIR/.venv/bin/python" ]]; then
    ok "RLM venv already exists"
  else
    python3 -m venv "$RLM_DIR/.venv" \
      && "$RLM_DIR/.venv/bin/pip" install --quiet mcp rlms \
      && ok "RLM venv created (mcp + rlms installed)" \
      || warn "RLM venv setup failed — try manually: python3 -m venv $RLM_DIR/.venv && $RLM_DIR/.venv/bin/pip install mcp rlms"
  fi
else
  warn "RLM server not found at $RLM_DIR"
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
  "DEEPSEEK_API_KEY:Optional — for DeepSeek provider"
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
  info "Add missing keys to your shell profile or .env file (see env.example)"
fi

# --- Done ---
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  OpenCode setup complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
info "Config location: $CONFIG_DST (symlink -> $CONFIG_SRC)"
info "Run 'opencode' to start"
