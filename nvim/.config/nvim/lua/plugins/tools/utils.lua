local M = {}

--- Detect the base branch (master, main, or develop) for the current repo
---@return string branch
function M.detect_base_branch()
  local candidates = { "master", "main", "develop" }

  for _, branch in ipairs(candidates) do
    -- Check remote ref exists
    local ok =
      vim.fn.systemlist("git rev-parse --verify origin/" .. branch .. " 2>/dev/null")
    if vim.v.shell_error == 0 and #ok > 0 then
      return "origin/" .. branch
    end
    -- Fallback: check local branch
    local local_ok =
      vim.fn.systemlist("git rev-parse --verify " .. branch .. " 2>/dev/null")
    if vim.v.shell_error == 0 and #local_ok > 0 then
      return branch
    end
  end

  -- Last resort: HEAD (compare with last commit)
  return "HEAD"
end

--- Open Diffview in MR-style (three-dot diff: base...HEAD).
--- Shows ONLY commits introduced on the current branch relative to base,
--- exactly like the "Changes" tab of a GitLab merge request.
function M.diff_open()
  local base = M.detect_base_branch()
  -- Strip "origin/" prefix: three-dot diff needs a local-ish ref name,
  -- the merge-base is resolved identically for origin/<branch>...HEAD.
  local short = base:gsub("^origin/", "")
  vim.cmd("DiffviewOpen " .. short .. "..." .. "HEAD")
end

--- Open Diffview in full two-dot diff (base..HEAD).
--- Shows the full difference between the base branch tip and HEAD,
--- including any commits that landed on base after the branch point.
function M.diff_open_full()
  local base = M.detect_base_branch()
  local short = base:gsub("^origin/", "")
  vim.cmd("DiffviewOpen " .. short)
end

return M
