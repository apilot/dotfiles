-- OpenCode AI assistant (opencode.nvim v0.14+: server model)
-- Начиная с v0.14 плагин подключается к серверу opencode (--port),
-- а TUI запускается/тогглится через snacks.terminal.
local opencode_cmd = "opencode --port"
local snacks_terminal_opts = { win = { position = "right", enter = false } }

return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*", -- Latest stable release
    dependencies = {
      {
        "folke/snacks.nvim",
        optional = true,
        opts = {
          input = {}, -- улучшает Ask (completions/highlight)
          picker = { -- улучшает Select
            actions = {
              opencode_send = function(picker)
                local items = vim.tbl_map(function(item)
                  return item.file
                      and require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
                      or item.text
                end, picker:selected({ fallback = true }))
                require("opencode").prompt(table.concat(items, ", ") .. " ")
              end,
            },
            win = {
              input = {
                keys = {
                  ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                },
              },
            },
          },
        },
      },
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Автозапуск TUI-сервера opencode при первом обращении, если сервер не найден
        server = {
          start = function()
            require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
          end,
        },
      }

      vim.o.autoread = true

      -- Keymaps
      -- Спросить opencode про текущий буфер/selection
      vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ") end, { desc = "Ask opencode" })
      -- Выбрать prompt / command / server
      vim.keymap.set({ "n", "x" }, "<leader>ox", function() require("opencode").select() end, { desc = "Select opencode action" })
      -- Toggle TUI opencode (вместо убранного в v0.14 метода toggle())
      vim.keymap.set({ "n", "t" }, "<leader>ot", function()
        require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
      end, { desc = "Toggle opencode TUI" })
      -- Скролл сессии opencode (пока TUI не в фокусе)
      vim.keymap.set("n", "<leader>ou", function() require("opencode").command("session.half.page.up") end, { desc = "Opencode scroll up" })
      vim.keymap.set("n", "<leader>od", function() require("opencode").command("session.half.page.down") end, { desc = "Opencode scroll down" })
    end,
  },
}
