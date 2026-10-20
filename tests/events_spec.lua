local state = require "ignition.state"
local config = require "ignition.config"
local events = require "ignition.events"

local captured = {}

local function listen(pattern)
  vim.api.nvim_create_autocmd("User", {
    pattern = pattern,
    callback = function(args)
      captured[#captured + 1] = { pattern = pattern, data = vim.deepcopy(args.data) }
    end,
  })
end

T.it("state.set running emite IgnitionStart", function()
  captured = {}
  listen "IgnitionStart"
  state.set("running", { action = "Run", cwd = "C:/p", filetype = "go" })
  T.eq(1, #captured)
  T.eq("IgnitionStart", captured[1].pattern)
  T.eq("go", captured[1].data.filetype)
end)

T.it("state.set success emite IgnitionSuccess y IgnitionExit", function()
  captured = {}
  listen "IgnitionSuccess"
  listen "IgnitionExit"

  state.set("running", { action = "Run", cwd = "C:/p", filetype = "py" })
  captured = {} -- borrar el Start
  state.set("success", { code = 0 })

  local patterns = {}
  for _, c in ipairs(captured) do
    patterns[#patterns + 1] = c.pattern
  end
  table.sort(patterns)
  T.eq("IgnitionExit", patterns[1])
  T.eq("IgnitionSuccess", patterns[2])
  T.eq("success", captured[2].data.status)
  T.eq(0, captured[2].data.code)
  T.eq("py", captured[2].data.filetype, "conserva filetype del job")
end)

T.it("state.set failed emite IgnitionFailed y IgnitionExit", function()
  captured = {}
  listen "IgnitionFailed"
  listen "IgnitionExit"
  state.set("running", {})
  captured = {}
  state.set("failed", { code = 1 })

  local has_failed, has_exit = false, false
  for _, c in ipairs(captured) do
    if c.pattern == "IgnitionFailed" then
      has_failed = true
      T.eq(1, c.data.code)
    elseif c.pattern == "IgnitionExit" then
      has_exit = true
    end
  end
  T.truthy(has_failed)
  T.truthy(has_exit)
end)

T.it("state.set cancelled emite IgnitionCancelled y IgnitionExit", function()
  captured = {}
  listen "IgnitionCancelled"
  listen "IgnitionExit"
  state.set("running", {})
  captured = {}
  state.set "cancelled"

  local has_cancelled, has_exit = false, false
  for _, c in ipairs(captured) do
    if c.pattern == "IgnitionCancelled" then
      has_cancelled = true
    elseif c.pattern == "IgnitionExit" then
      has_exit = true
    end
  end
  T.truthy(has_cancelled)
  T.truthy(has_exit)
end)

T.it("state.set idle no emite eventos", function()
  captured = {}
  listen "IgnitionStart"
  listen "IgnitionExit"
  state.set "idle"
  T.eq(0, #captured)
end)

T.it("events.enabled=false no emite nada", function()
  captured = {}
  listen "IgnitionStart"
  listen "IgnitionExit"
  listen "IgnitionSuccess"

  local saved = config.options.events.enabled
  config.options.events.enabled = false
  state.set("running", {})
  state.set("success", { code = 0 })
  T.eq(0, #captured)
  config.options.events.enabled = saved
end)
