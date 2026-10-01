import type { Plugin } from "@opencode-ai/plugin"

// Headless Chrome for system specs (ferrum/cuprite reads BROWSER_PATH).
// Installed at ~/.local/share/browsers (moved from volatile /tmp).
const BROWSER_PATH = `${process.env["HOME"]}/.local/share/browsers/chrome-headless-shell/linux-153.0.8010.47/chrome-headless-shell-linux64/chrome-headless-shell`

export default (async () => {
  return {
    "shell.env": async (_input, output) => {
      // Respect an explicit override if one is already set.
      if (!output.env["BROWSER_PATH"]) output.env["BROWSER_PATH"] = BROWSER_PATH
    },
  }
}) satisfies Plugin
