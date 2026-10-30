# Хоткеи, независимые от раскладки (X keycode)

- **Дата**: 2026-10-30
- **Статус**: review
- **Ветка**: gentoo (cherry-pick применён на hypr_text/master/ubuntu; легаси-файлы конвертированы)

## Проблема

Буквенно-цифровые хоткеи были привязаны к keysym (`D`, `T`, `1`…). При переключении
раскладки us → ru (grp:win_space_toggle) русские keysym не совпадают, и хоткеи
перестают работать. Требование: хоткеи должны работать на любой раскладке одинаково
и не пересекаться.

## Решение

Привязки букв/цифр переводятся на X keycode: `code:N` в Lua API (`hl.bind`),
«голое» число в hyprlang (`bind = ...`). Keycode — физическая клавиша, от раскладки
не зависит. Layout-независимые keysym остаются как есть: Return, Tab, space, escape,
стрелки, Print, XF86*, mouse, F1–F12.

Таблица преобразования: Q=24 W=25 E=26 R=27 T=28 Y=29 U=30 I=31 O=32 P=33 A=38
S=39 D=40 F=41 H=43 J=44 K=45 L=46 ;=47 Z=52 X=53 C=54 V=55 B=56 N=57 M=58;
цифры 1..9,0 → 10..19.

Проверено на установленном Hyprland 0.56.2: Lua `code:N` работает, «голое» число
в hyprlang = keycode (36/65/122/232 уже использовались).

## Изменённые файлы (ветка gentoo)

1. `hyprland-noctalia/.config/hypr/hyprland.lua` — все буквы/цифры → `code:N`;
   циклы рабочих столов → `mainMod .. " + code:" .. (i + 9)`; resize-submap L/H/K/J
   → `code:46/43/45/44` (без SHIFT — см. «Семантика keysym в 0.56.2»).
2. `hyprlands/.config/hypr/hyprland.conf` — то же «голыми» числами; `ctrl,d` → 40;
   submap `binde=,L` → `binde=,46` и т.д.; lock-with-monitors перенесён с
   SUPER+SHIFT+L на SUPER+ALT+L (конфликт с nav movewindow, см. ниже).
3. `hyprlands/.config/hypr/nav_bindings_standard.conf` — H/J/K/L → 43/44/45/46.
4. `hyprlands/.config/hypr/nav_bindings_alternative.conf` — то же + semicolon → 47.
5. `hyprland-common/.config/hypr/scripts/set_nav_mode.sh` — `clear_nav_bindings()`:
   основной путь `hyprctl keyword unbind MODS, KEYCODE` (бинды от `keyword bind`
   не имеют displayKey и hl.unbind их не находит); `hl.unbind` — фолбэк для
   Lua-сессии; keysym-формы — для старых биндов без перезагрузки конфига.
6. `hyprland-caelestia/.config/hypr/hyprland/keybinds.conf` — то же; удалён
   дублирующий бинд «Wallpaper restart» (SUPER+SHIFT+C конфликтовал с
   `notifications clear` — решение владельца); lockScreen перенесён на
   SUPER+ALT+L (см. ниже).

## Решения владельца

- `notifications clear` остаётся на SUPER+SHIFT+C в caelestia; дубль wpaperd-restart удалён.
- Цифры тоже переводятся в keycode.
- Этот проход — только ветка gentoo.

## Семантика keysym в Hyprland 0.56.2 (по исходникам, ревью)

- Событие-resolve keysym идёт через статический `m_xkbTranslationState` БЕЗ
  модификаторов → всегда базовый (нижний) регистр; матч keysym-биндов
  регистронезависим (`KBKEYLOWER`). modmask при этом сверяется точно.
- Следствие: `bind = ,L` (заглавный keysym) в 0.56.2 срабатывает на голом L,
  Shift НЕ требуется. Поэтому submap `binde=,L` → `binde=,46` (не SHIFT,46),
  а SUPER+ALT+L (lock) → SUPER+ALT+code:46 — поведение идентичное исходному.

## Заметки по конфликтам

- caelestia: SUPER+CTRL+L (lockScreen) и SUPER+CTRL+l (hy3 movefocus) в 0.56.2
  матчат одну и ту же физическую комбинацию — скрытый конфликт существовал и
  раньше. lockScreen перенесён на SUPER+ALT+L: конвенция «lock = SUPER+ALT+L»
  теперь во всех трёх вариантах (noctalia lua, hyprlands, caelestia), коллизий нет.
- hyprlands: SUPER+SHIFT+L (lock-with-monitors) пересекался с nav-биндами
  SUPER SHIFT+H/J/K/L (movewindow) — nav, применяясь на лету, затирал lock.
  Перенесён на SUPER+ALT+L.
- nav_bindings_standard vs alternative — взаимоисключающие режимы (скрипт
  разбирает один набор перед применением другого), «дубли» между ними — by design.
- Аудит дублей (mods+keycode) по каждому варианту и режиму — 0 пересечений.
- Известное вне-скоуп ограничение: caelestia вызывает set_nav_mode.sh, но
  nav_bindings_*.conf в её каталоге нет (фича там спит, уведомление вводит в
  заблуждение). Историческое; при желании — скопировать nav-файлы в caelestia.

## Валидация

- `Hyprland --verify-config` для lua — без ошибок (warnings hy3 при verify ожидаемы).
- Re-grep: в key-полях не осталось букв/цифр-keysym (кроме whitelisted).
- Аудит пересечений (mods+key) по каждому из 4 conf-файлов — без дублей.
- Запрещено и не выполнялось: `hyprctl reload`, live-операции, git commit.
