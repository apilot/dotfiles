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
# 3a. LS_COLORS — Catppuccin Mocha (truecolor; kitty и kitten ssh поддерживают)
#     Экспортируется ДО загрузки плагинов: его читают eza, fzf-tab и меню
#     таб-комплишена (zstyle в секции 7).
# -----------------------------------------------------------------------------
_ls_colors=(
  # Типы файлов: каталоги blue, симлинки teal, исполняемые green
  'di=1;38;2;137;180;250' 'ln=38;2;148;226;213' 'or=38;2;243;139;168'
  'mi=38;2;243;139;168' 'pi=38;2;250;179;135' 'so=38;2;249;234;175'
  'bd=1;38;2;249;234;175' 'cd=1;38;2;249;234;175' 'ex=1;38;2;166;227;161'
  'su=38;2;249;234;175' 'sg=38;2;249;234;175' 'tw=38;2;137;220;235'
  'ow=38;2;137;220;235' 'st=38;2;137;180;250' 'do=38;2;137;220;235'
  # Архивы и образы — red
  '*.tar=38;2;243;139;168' '*.tgz=38;2;243;139;168' '*.arj=38;2;243;139;168'
  '*.taz=38;2;243;139;168' '*.lha=38;2;243;139;168' '*.lz4=38;2;243;139;168'
  '*.lzh=38;2;243;139;168' '*.lzma=38;2;243;139;168' '*.tlz=38;2;243;139;168'
  '*.txz=38;2;243;139;168' '*.tzo=38;2;243;139;168' '*.t7z=38;2;243;139;168'
  '*.zip=38;2;243;139;168' '*.z=38;2;243;139;168' '*.dz=38;2;243;139;168'
  '*.gz=38;2;243;139;168' '*.lz=38;2;243;139;168' '*.zoo=38;2;243;139;168'
  '*.rar=38;2;243;139;168' '*.cpio=38;2;243;139;168' '*.rpm=38;2;243;139;168'
  '*.deb=38;2;243;139;168' '*.gem=38;2;243;139;168' '*.iso=38;2;243;139;168'
  '*.img=38;2;243;139;168' '*.xz=38;2;243;139;168' '*.bz2=38;2;243;139;168'
  '*.tbz=38;2;243;139;168' '*.7z=38;2;243;139;168' '*.apk=38;2;243;139;168'
  '*.jar=38;2;243;139;168' '*.war=38;2;243;139;168'
  # Изображения и аудио — pink
  '*.jpg=38;2;245;194;231' '*.jpeg=38;2;245;194;231' '*.png=38;2;245;194;231'
  '*.gif=38;2;245;194;231' '*.bmp=38;2;245;194;231' '*.tif=38;2;245;194;231'
  '*.tiff=38;2;245;194;231' '*.webp=38;2;245;194;231' '*.svg=38;2;245;194;231'
  '*.xcf=38;2;245;194;231' '*.psd=38;2;245;194;231' '*.ico=38;2;245;194;231'
  '*.heic=38;2;245;194;231' '*.mp3=38;2;245;194;231' '*.ogg=38;2;245;194;231'
  '*.flac=38;2;245;194;231' '*.wav=38;2;245;194;231' '*.aac=38;2;245;194;231'
  '*.m4a=38;2;245;194;231' '*.opus=38;2;245;194;231' '*.wma=38;2;245;194;231'
  # Видео — mauve
  '*.mp4=38;2;203;166;247' '*.mkv=38;2;203;166;247' '*.webm=38;2;203;166;247'
  '*.avi=38;2;203;166;247' '*.mov=38;2;203;166;247' '*.wmv=38;2;203;166;247'
  '*.flv=38;2;203;166;247' '*.m4v=38;2;203;166;247' '*.mpg=38;2;203;166;247'
  '*.mpeg=38;2;203;166;247' '*.3gp=38;2;203;166;247'
  # Документы — peach/lavender
  '*.pdf=38;2;250;179;135' '*.doc=38;2;180;190;254' '*.docx=38;2;180;190;254'
  '*.odt=38;2;180;190;254' '*.rtf=38;2;180;190;254' '*.epub=38;2;180;190;254'
  '*.csv=38;2;180;190;254' '*.tsv=38;2;180;190;254' '*.xlsx=38;2;180;190;254'
  '*.pptx=38;2;180;190;254'
  # Шрифты — peach
  '*.ttf=38;2;250;179;135' '*.otf=38;2;250;179;135' '*.woff=38;2;250;179;135'
  '*.woff2=38;2;250;179;135'
  # Код: шелл/ruby-скрипты green, python/js/ts yellow, конфиги peach, C blue
  '*.sh=38;2;166;227;161' '*.bash=38;2;166;227;161' '*.zsh=38;2;166;227;161'
  '*.ksh=38;2;166;227;161' '*.fish=38;2;166;227;161' '*.vim=38;2;166;227;161'
  '*.rb=38;2;243;139;168' '*.gemspec=38;2;243;139;168' '*.rake=38;2;243;139;168'
  '*.py=38;2;249;234;175' '*.js=38;2;249;234;175' '*.mjs=38;2;249;234;175'
  '*.cjs=38;2;249;234;175' '*.jsx=38;2;249;234;175' '*.ts=38;2;249;234;175'
  '*.tsx=38;2;249;234;175' '*.json=38;2;180;190;254' '*.md=38;2;180;190;254'
  '*.markdown=38;2;180;190;254'
  '*.yml=38;2;250;179;135' '*.yaml=38;2;250;179;135' '*.toml=38;2;250;179;135'
  '*.ini=38;2;250;179;135' '*.cfg=38;2;250;179;135' '*.conf=38;2;250;179;135'
  '*.sql=38;2;250;179;135' '*.rs=38;2;250;179;135' '*.java=38;2;250;179;135'
  '*.c=38;2;137;180;250' '*.h=38;2;137;180;250' '*.cpp=38;2;137;180;250'
  '*.hpp=38;2;137;180;250' '*.cc=38;2;137;180;250' '*.hh=38;2;137;180;250'
  '*.go=38;2;137;220;235' '*.dart=38;2;137;220;235' '*.html=38;2;137;220;235'
  '*.htm=38;2;137;220;235'
  '*.css=38;2;203;166;247' '*.scss=38;2;203;166;247' '*.sass=38;2;203;166;247'
  '*.php=38;2;203;166;247' '*.kt=38;2;245;194;231' '*.swift=38;2;245;194;231'
  '*.gguf=38;2;203;166;247'
  # Служебное — overlay (приглушённое) + ключи yellow
  '*.lock=38;2;108;112;134' '*.log=38;2;108;112;134' '*.bak=38;2;108;112;134'
  '*.old=38;2;108;112;134' '*.orig=38;2;108;112;134' '*.swp=38;2;108;112;134'
  '*.pem=38;2;249;234;175' '*.key=38;2;249;234;175' '*.crt=38;2;249;234;175'
)
export LS_COLORS="${(j.:.)_ls_colors}"
unset _ls_colors

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
#    atload — ЦВЕТНОЕ меню таб-комплишена: OMZL::completion.zsh сам ставит
#    пустой list-colors, поэтому переопределяем ПОСЛЕ его загрузки из LS_COLORS
# -----------------------------------------------------------------------------
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
    atload'zstyle ":completion:*" list-colors ${(s.:.)LS_COLORS}' \
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
# Цветной вывод (auto = только при выводе в терминал, в pipe цвета отключаются)
alias ls='ls --color=auto'      # чинит всё семейство: ll/la/lt/l из OMZP::common-aliases рекурсивно
alias grep='grep --color=auto'  # дублирует OMZ-алиас, но работает сразу — до TURBO-загрузки плагина
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c'                # iproute2: короткая форма (длинная -color=auto этой версией не поддерживается)
command -v tree >/dev/null || alias tree='eza --tree --level=2 --git'

alias ld="lazydocker"
alias lg="lazygit"
alias ee="eza -l"
alias docker-compose="docker compose"
alias hyprpm='CXXFLAGS=-I/usr/include/lua5.4 hyprpm'
if [[ -n "$KITTY_WINDOW_ID" ]]; then
  alias kssh="kitten ssh"
fi

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
