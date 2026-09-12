-- Options in this file override LazyVim defaults.
-- LazyVim sources lua/config/options.lua AFTER lazyvim.config.options,
-- unlike config/editor.lua which init.lua requires BEFORE config.lazy
-- (so LazyVim's own `spelllang = "en"` was overwriting the spell settings).
-- Moved here from config/editor.lua lines 76-78 on 2026-09-07.

-- Spell checking: en + Russian (both regions of ru.utf-8.spl:
-- ru_ru = е-spellings, ru_yo = ё-spellings; both needed to accept
-- «елка» and «ёлка» variants)
vim.opt.spelllang = { "en_us", "ru_yo", "ru_ru" }
vim.opt.spell = true
