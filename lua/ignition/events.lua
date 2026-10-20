-- Events `Ignition*`: autocmds User que se emiten cuando cambia el estado
-- central de ejecución. Así el usuario puede reaccionar (notificaciones,
-- linters, statusline...) sin acoplar su código a los internos del plugin.
--
-- Escucha con:
--   vim.api.nvim_create_autocmd("User", { pattern = "IgnitionSuccess", callback = fn })
-- Los callbacks reciben un objeto con status/action/cwd/filetype/buf/code.
--
-- Emitidos (mapean a `state.lua`):
--   IgnitionStart     → estado "running"
--   IgnitionExit      → cualquier estado final (success/failed/cancelled)
--   IgnitionSuccess   → "success"
--   IgnitionFailed    → "failed"
--   IgnitionCancelled → "cancelled"
local config = require "ignition.config"

local M = {}

local MAP = {
  running = "IgnitionStart",
  cancelled = "IgnitionCancelled",
  failed = "IgnitionFailed",
  success = "IgnitionSuccess",
}

-- Estados terminales que además disparan IgnitionExit.
local EXIT = { cancelled = true, failed = true, success = true }

function M.emit(status, s)
  if not config.options.events.enabled then
    return
  end

  local data = {
    status = status,
    action = s.action,
    cwd = s.cwd,
    filetype = s.filetype,
    buf = s.buf,
    code = s.code,
  }

  local name = MAP[status]

  if name then
    vim.api.nvim_exec_autocmds("User", {
      pattern = name,
      modeline = false,
      data = data,
    })
  end

  if EXIT[status] then
    vim.api.nvim_exec_autocmds("User", {
      pattern = "IgnitionExit",
      modeline = false,
      data = data,
    })
  end
end

return M
