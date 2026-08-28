# ~/.zshenv — загружается zsh для ВСЕХ shell-ов (интерактивных и нет)
# Здесь только PATH и env vars, нужные везде.
# Секреты — в ~/.zsh/secrets.zsh (загружается из .zshrc)
# mise: активация в .zshrc (eval "$(mise activate zsh)"), бинарник в ~/.local/bin

# Audio plugins
export LADSPA_PATH=/usr/lib64/ladspa
export LV2_PATH=/usr/lib64/lv2

# Bun (opencode) не видит системные CA (вкл. Russian Trusted CA) — чинит
# "unknown certificate verification error" при стриме от z.ai
export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

# . "$HOME/.cargo/env"
