# =============================================================================
# ~/.zshrc — Gentoo + OpenRC, zinit + Powerlevel10k (сценарий B)
# Мигрировано с oh-my-zsh 2026-07-17. Бэкап: ~/dotfiles/archives/
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Powerlevel10k instant prompt (ДОЛЖНО быть в самом верху .zshrc)
# -----------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------------------------------------------------------
# 2. TERM: kitty только если kitty запущен И terminfo доступен.
# -----------------------------------------------------------------------------
if [[ "$TERM_PROGRAM" == "kitty" ]] && infocmp xterm-kitty &>/dev/null; then
  export TERM="xterm-kitty"
fi

# -----------------------------------------------------------------------------
# 3. Конфиг плагинов (env vars должны быть заданы ДО загрузки плагинов)
# -----------------------------------------------------------------------------
# colorize: chroma не установлен, pygments (pygmentize) есть в системе
ZSH_COLORIZE_TOOL=pygments
ZSH_COLORIZE_STYLE="monokai"

# zsh-vi-mode: фикс bracketed paste — ZLE engine корректно обрабатывает вставку в normal mode
ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_ZLE

# -----------------------------------------------------------------------------
# 4. Zinit bootstrap
# -----------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[[ ! -d "$ZINIT_HOME" ]] && \
  git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# -----------------------------------------------------------------------------
# 5. Тема: Powerlevel10k (СИНХРОННО — для instant prompt)
# -----------------------------------------------------------------------------
zinit ice depth=1
zinit light romkatv/powerlevel10k

# -----------------------------------------------------------------------------
# 6. fzf-tab (СИНХРОННО — должен загрузиться до compinit, как требует README)
#    blockf — не давать zinit добавлять в fpath, creinstall — переустановка completions
# -----------------------------------------------------------------------------
zinit ice lucid blockf atpull'zinit creinstall -q .' \
  compile'{src/*/*.zsh,src/*.zsh}'
zinit light Aloxaf/fzf-tab

# zsh-vi-mode — СИНХРОННО (требует инициализации ZLE до первого prompt)
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode

# OMZ lib::git.zsh — нужен OMZP::git / git-extras / git-flow (определения current_branch и т.д.)
zinit snippet OMZL::git.zsh

# -----------------------------------------------------------------------------
# 7. OMZ library + completions setup (TURBO — после первого prompt)
#    zicompinit — компилирует completions ОДИН раз (не дважды как в OMZ)
#    zicdreplay — реплей compdef вызовов из плагинов, загруженных ранее
# -----------------------------------------------------------------------------
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        OMZL::completion.zsh \
    OMZL::history.zsh

# -----------------------------------------------------------------------------
# 8. OMZ plugins (TURBO)
#    Полный набор для Ruby on Rails разработки + utility
# -----------------------------------------------------------------------------
zinit wait lucid for \
    OMZP::git \
    OMZP::git-extras \
    OMZP::common-aliases \
    OMZP::history \
    OMZP::colorize \
    OMZP::colored-man-pages \
    OMZP::command-not-found \
    OMZP::cp \
    OMZP::extract \
    OMZP::sudo \
    OMZP::branch \
    OMZP::bundler \
    OMZP::gem \
    OMZP::rake \
    OMZP::ruby \
    OMZP::rsync \
    OMZP::dirhistory \
    OMZP::aliases \
    OMZP::jsontools \
    OMZP::rails

# git-flow — требует svn ice (dev-vcs/subversion) для загрузки всего каталога плагина.
# Без svn — выдаёт "_git-flow: no such file" warning. Раскомментировать после `emerge dev-vcs/subversion`.
# zinit ice wait lucid svn
# zinit snippet OMZP::git-flow

# -----------------------------------------------------------------------------
# 9. External plugins (TURBO)
# -----------------------------------------------------------------------------
zinit wait lucid for \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    zsh-users/zsh-autosuggestions \
    MichaelAquilina/zsh-you-should-use \
    fdellwing/zsh-bat \
    hlissner/zsh-autopair \
    wfxr/forgit

# ⚠️ unixorn/fzf-zsh-plugin УБРАН — дублировал fzf keybindings/completion из системы,
# конфликтовал с custom Ctrl+T widget, и требовал ~/.fzf/fzf.zsh (portage fzf не создаёт).

# zsh-history-substring-search — отдельной строкой (нужны bindkey после загрузки)
# Highlight в стиле Catppuccin Mocha: БЕЗ заливки фоном, чтобы syntax-highlighting
# оставался видим. Только bold + underline — мягкое, но чёткое выделение.
zinit ice wait lucid atload'\
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bold,underline"; \
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="bold"; \
  bindkey "^[[A" history-substring-search-up; \
  bindkey "^[[B" history-substring-search-down; \
  bindkey -M vicmd "k" history-substring-search-up; \
  bindkey -M vicmd "j" history-substring-search-down'
zinit light zsh-users/zsh-history-substring-search

# -----------------------------------------------------------------------------
# 10. zsh-syntax-highlighting — ПОСЛЕДНИМ (требование проекта)
#     Должен грузиться после всех других плагинов, оборачивающих zle widgets.
#     Catppuccin Mocha тема (единая для всех компонентов) грузится ПОСЛЕ плагина.
# -----------------------------------------------------------------------------
zinit ice wait lucid \
  atinit"ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)" \
  atload"[[ -f $HOME/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh ]] && \
    source $HOME/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh"
zinit light zsh-users/zsh-syntax-highlighting

# -----------------------------------------------------------------------------
# 11. FZF: системные key-bindings + completion (TURBO — после compinit)
#     Системные файлы содержат compdef, должны грузиться после compinit
# -----------------------------------------------------------------------------
zinit ice wait lucid id-as"fzf-system-keybindings"
zinit snippet /usr/share/fzf/key-bindings.zsh

zinit ice wait lucid id-as"fzf-system-completion"
zinit snippet /usr/share/fzf/completion.zsh

# -----------------------------------------------------------------------------
# 12. Environment & PATH
# -----------------------------------------------------------------------------
export EDITOR=nvim

# XDG
export XDG_CONFIG_HOME="$HOME/.config"

# Локальные бинарники
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# yarn
export PATH="$HOME/.yarn/bin:$PATH"

# -----------------------------------------------------------------------------
# 13. mise: менеджер версий (заменил rbenv + nvm)
#     node: 16.20.2, 18.20.5, 20.18.1, 22.12.0, 22.13.0 (default), 24.x
#     ruby: 3.3.6, 3.4.4, 3.4.5 (default), 3.4.9, 3.4.10
#     Авто-переключение по .nvmrc / .ruby-version включено
# -----------------------------------------------------------------------------
eval "$(mise activate zsh)"

# -----------------------------------------------------------------------------
# 13a. zoxide: умный cd (j/ji команды). Заменяет autojump/z.sh. Бинарник /usr/bin/zoxide
#      Используем --cmd j (jump), т.к. дефолтный z конфликтует с zinit alias `zi`
#      j   <query>  — прыгнуть в директорию по подстроке
#      ji  [query]  — интерактивный выбор через fzf
# -----------------------------------------------------------------------------
eval "$(zoxide init zsh --cmd j)"

# -----------------------------------------------------------------------------
# 13b. Atuin: SQLite-история с fuzzy-поиском. Заменяет дефолтный Ctrl+R.
#     --disable-up-arrow: Up/Down остаются за zsh-history-substring-search
#     Бинарник /usr/bin/atuin. Конфиг: ~/.config/atuin/config.toml
# -----------------------------------------------------------------------------
eval "$(atuin init zsh --disable-up-arrow)"

# -----------------------------------------------------------------------------
# 14. FZF_DEFAULT_OPTS (Catppuccin Mocha)
# -----------------------------------------------------------------------------
export FZF_DEFAULT_OPTS="--preview 'fzf-preview.sh {}' --height 40% --tmux bottom,40% --layout reverse --border top --info=inline --border --margin=1 --padding=1 \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

# -----------------------------------------------------------------------------
# 15. ssh-agent: один агент на все shell-ы (переиспользуется через ~/.ssh/agent.env)
# -----------------------------------------------------------------------------
source "$HOME/.zsh/functions/ssh-agent-reuse.zsh"

# -----------------------------------------------------------------------------
# 16. Aliases
# -----------------------------------------------------------------------------
alias ld="lazydocker"
alias lg="lazygit"
alias ee="eza -l"
alias docker-compose="docker compose"

# DisplayLink (безопасное отключение/подключение монитора)
alias dl-off='sudo rc-service displaylink stop'
alias dl-on='sudo rc-service displaylink zap && sudo rc-service displaylink start && hyprctl keyword monitor DVI-I-1,1920x1080@60,0x0,1'

# HDMI (NVIDIA)
alias hdmi-off='hyprctl keyword monitor HDMI-A-1,disable'
alias hdmi-on='hyprctl keyword monitor HDMI-A-1,1920x1080@75,1920x0,1'

# Rails-алиасы (rs/rc/rg/rk/rdm/...) добавляет плагин OMZP::rails через zinit.
# Для bundle exec используй: be rails s (alias be='bundle exec' от OMZP::bundler).

# GnuCash с русским интерфейсом и темой Catppuccin
alias gnucash='gnucash-ru'

# Flutter
alias emu-kvm='emulator -avd flutter_emulator -gpu host -accel on -memory 4096 -cores 4'
alias frun='flutter run -d emulator-5554'

# RAG embedding server
alias rag-embed="nohup llama-server -m /mnt/docs/llama/models/embeddings/nomic-embed-text-v1.5.Q8_0.gguf --embedding --port 8081 --host 127.0.0.1 -c 8192 -t 8 > /tmp/rag-embed.log 2>&1 &"

# -----------------------------------------------------------------------------
# 17. Powerlevel10k: тема и quiet instant prompt (отключает warnings в логах)
# -----------------------------------------------------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# -----------------------------------------------------------------------------
# 18. Secrets (API keys) — not in version control
# -----------------------------------------------------------------------------
[[ -f "$HOME/.zsh/secrets.zsh" ]] && source "$HOME/.zsh/secrets.zsh"

# -----------------------------------------------------------------------------
# 19. opencode
# -----------------------------------------------------------------------------
export PATH="$HOME/.opencode/bin:$PATH"
export OPENCODE_TIMEOUT=7200
alias opencode='opencode --agent OpenCoder'

# -----------------------------------------------------------------------------
# 20. pnpm
# -----------------------------------------------------------------------------
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# -----------------------------------------------------------------------------
# 21. FZF word search (по слову под курсором)
# -----------------------------------------------------------------------------
source "$HOME/.zsh/functions/fzf-word-search.zsh"

# -----------------------------------------------------------------------------
# 22. Flutter & Android SDK
# -----------------------------------------------------------------------------
export PATH="$PATH:$HOME/development/flutter/bin"

export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_AVD_HOME="$HOME/.android/avd"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/build-tools/36.0.0"

# -----------------------------------------------------------------------------
# 23. bun
# -----------------------------------------------------------------------------
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# -----------------------------------------------------------------------------
# 24. FZF горячие клавиши
# -----------------------------------------------------------------------------
# Ctrl+T  — поиск файлов (стандартный fzf-file-widget, вставка пути в строку)
# Alt+C   — поиск директорий + cd (стандартный fzf-cd-widget)
# Ctrl+R  — Atuin (история с fuzzy по всей БД, мощный)
# Alt+H   — custom: fzf по истории zsh с предзаполненным фильтром из текущей строки

# -----------------------------------------------------------------------------
# 25. Alt+H — fzf по истории zsh с pre-filled query из текущей строки
#     Печатаешь "bundle" → Alt+H → fzf открывается уже отфильтрованным.
#     Уникальные команды, последние сверху. ENTER — вставить в строку.
#     Дополняет history-substring-search (↑↓) и Atuin (Ctrl+R).
# -----------------------------------------------------------------------------
fzf-history-query() {
  emulate -L zsh
  local selected
  # ${(u)history} — уникальные записи истории; --tac — последние сверху; --no-sort — порядок как в истории
  selected=$(print -rl ${(u)history} 2>/dev/null \
    | fzf --no-sort --tac \
        --height=70% --layout=reverse --border --ansi \
        --prompt='history > ' \
        --header="FILTER: '$LBUFFER'  |  ENTER: вставить  |  ESC: отмена  |  Ctrl+R: Atuin" \
        --query="$LBUFFER" \
        --preview-window=hidden)
  if [ -n "$selected" ]; then
    LBUFFER="${selected}"
  fi
  zle reset-prompt
}
zle -N fzf-history-query
bindkey '^[h' fzf-history-query            # Alt+H (emacs keymap)
bindkey -M viins '^[h' fzf-history-query   # Alt+H в vi insert mode
bindkey -M vicmd '^[h' fzf-history-query   # Alt+H в vi normal mode

# Local llama.cpp Qwen2.5-Coder server (qwen-up / qwen-down / qwen-status / qwen-log)
source "$HOME/.zsh/functions/llama-qwen.zsh"
