local config = require "ignition.config"

local M = {}

-- Grupos propios del plugin (defaults): se enlazan a las opciones del tema
-- (config.options.picker/terminal). Al definirlos con `default = true` no
-- pisan lo que el usuario ya haya definido (base46 / highlights override).
-- Así el picker y la terminal comparten el mismo color.
local GROUPS = {
  IgnitionActionRun = function()
    return config.options.picker.hl_run
  end,
  IgnitionActionBuild = function()
    return config.options.picker.hl_build
  end,
  IgnitionActionMisc = function()
    return config.options.picker.hl_misc
  end,
  IgnitionTermTitle = function()
    return config.options.terminal.hl_title or config.options.picker.hl_misc
  end,
  IgnitionTermOk = function()
    return config.options.terminal.hl_status_ok
  end,
  IgnitionTermErr = function()
    return config.options.terminal.hl_status_err
  end,
  IgnitionExitOk = function()
    return config.options.terminal.hl_exit_ok
  end,
  IgnitionExitErr = function()
    return config.options.terminal.hl_exit_err
  end,
}

-- Define (o reasocia) los grupos de resaltado del plugin. No sobreescribe
-- una definición previa del usuario.
function M.setup()
  for name, target in pairs(GROUPS) do
    local link = target()

    if link and link ~= "" then
      vim.api.nvim_set_hl(0, name, { link = link, default = true })
    end
  end
end

-- Grupos que el plugin expone (para documentarlos y consultarlos)
M.names = vim.tbl_keys(GROUPS)

return M