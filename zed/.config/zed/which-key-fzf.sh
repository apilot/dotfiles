#!/bin/bash
# Interactive which-key menu for Zed Editor with fzf
# Press Enter to see binding in Zed (just shows info)

set -e

# Define all keybindings
cat << 'EOF' | fzf --height 90% --layout=reverse --border --prompt "Which-Key> " --header "Press ESC to close | Search keybindings" --ansi
[1;36m═══ QUICK ACTIONS ═══[0m
  Space w    Save file
  Space q    Close file
  Space Q    Quit Zed
  Space e    File explorer

[1;36m═══ FILES (leader+f) ═══[0m
  Space ff   Find files
  Space Space  Find files
  Space fg   Live grep (ripgrep)
  Space fr   Recent files
  Space fb   Buffers
  Space fc   Commands

[1;36m═══ GIT (leader+g) ═══[0m
  Space gg   LazyGit
  Space gs   Git status
  Space gc   Git commit
  Space gp   Git push

[1;36m═══ LSP (leader+l) ═══[0m
  Space lf   Format code
  Space ld   Go to definition
  Space li   Go to implementation
  Space lr   Find references
  Space ln   Rename symbol
  Space la   Code actions

[1;36m═══ WINDOWS (leader+w) ═══[0m
  Space we   Equalize windows
  Space wv   Split vertical
  Space wh   Split horizontal
  Space wq   Close window

[1;36m═══ NAVIGATION ═══[0m
  Ctrl+h     Left window
  Ctrl+j     Bottom window
  Ctrl+k     Top window
  Ctrl+l     Right window

[1;36m═══ TERMINAL (leader+t) ═══[0m
  Space tt   Toggle terminal

[1;36m═══ UI TOGGLES (leader+u) ═══[0m
  Space uz   Zen mode
  Space ul   Toggle left dock
  Space ur   Toggle right dock
  Space ub   Toggle bottom dock

[1;36m═══ VIM MODE ═══[0m
  i          Insert mode
  Esc        Normal mode
  dd         Delete line
  yy         Yank line
  p          Paste
  /          Search

[1;36m═══ ZED NATIVE ═══[0m
  Ctrl+Shift+P  Command palette
  Ctrl+P        Quick open
  Ctrl+Shift+F  Find in files
  Ctrl+B        Toggle sidebar
  Ctrl+`        Toggle terminal
EOF
