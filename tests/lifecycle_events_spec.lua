local lifecycle = require "ignition.lifecycle_events"
local engine = require "ignition.engine"

local function build(status, context)
  local e = engine.create {
    task_id = "run",
    context = context or { filetype = "go", cwd = "/tmp/x" },
    command = "go test ./...",
    now = 1000,
  }
  e = engine.start(e, 1001)
  e = engine.running(e, 1002)

  if status == "success" then
    e = engine.finish(e, { code = 0 }, 1005)
  elseif status == "failed" then
    e = engine.finish(e, { code = 1 }, 1005)
  elseif status == "cancelled" then
    e = engine.cancel(e, 1005)
  end

  return e
end

T.section("lifecycle_events: nombres por estado (EXEC-007)")

T.it("running emite IgnitionStart (paridad)", function()
  T.eq(lifecycle.event_for "running", "IgnitionStart")
  T.eq(lifecycle.names "running", { "IgnitionStart" })
end)

T.it("success emite IgnitionSuccess y IgnitionExit en ese orden", function()
  T.eq(lifecycle.names "success", { "IgnitionSuccess", "IgnitionExit" })
  T.truthy(lifecycle.exits "success")
end)

T.it("failed emite IgnitionFailed y IgnitionExit", function()
  T.eq(lifecycle.names "failed", { "IgnitionFailed", "IgnitionExit" })
  T.truthy(lifecycle.exits "failed")
end)

T.it("cancelled emite IgnitionCancelled y IgnitionExit", function()
  T.eq(lifecycle.names "cancelled", { "IgnitionCancelled", "IgnitionExit" })
  T.truthy(lifecycle.exits "cancelled")
end)

T.it("created/starting no emiten (paridad con events.lua)", function()
  T.eq(lifecycle.names "starting", {})
  T.eq(lifecycle.names "created", {})
  T.falsy(lifecycle.exits "starting")
  T.eq(lifecycle.event_for "created", nil)
end)

T.section("lifecycle_events: payload derivado de la Execution")

T.it("data transporta status/task/command/cwd/filetype/code", function()
  local exec = build "success"
  local d = lifecycle.data(exec)

  T.eq(d.status, "success")
  T.eq(d.action, "run")
  T.eq(d.task_id, "run")
  T.eq(d.command, "go")
  T.eq(d.cwd, "/tmp/x")
  T.eq(d.filetype, "go")
  T.eq(d.code, 0, "code del Result")
end)

T.it("failed transporta code != 0", function()
  local exec = build "failed"
  T.eq(lifecycle.data(exec).code, 1)
end)

T.it("cancelled sin result omite code (nil)", function()
  local exec = build "cancelled"
  T.eq(lifecycle.data(exec).code, nil)
end)

T.it("running (antes del result) omite code", function()
  local exec = build "running"
  T.eq(lifecycle.data(exec).status, "running")
  T.eq(lifecycle.data(exec).code, nil)
end)

T.it("cwd prefiere command.cwd (canónico) sobre ctx legacy", function()
  local e = engine.create {
    task_id = "run",
    context = { filetype = "go", cwd = "/tmp/legacy" },
    command = { executable = "go", args = { "run", "." }, cwd = "/tmp/proj" },
    now = 1000,
  }
  T.eq(lifecycle.data(e).cwd, "/tmp/proj")
end)

T.section("lifecycle_events: integration con el engine (EXEC-007)")

T.it("acceptance: el listener del engine y el mapeo producin la secuencia publica", function()
  local events_seen = {}
  engine.set_listener(function(exec)
    local transitions = lifecycle.for_transition(exec)
    for _, t in ipairs(transitions) do
      events_seen[#events_seen + 1] = t.name
    end
  end)

  local exec = engine.create { task_id = "run", command = "go run .", now = 1000 }
  exec = engine.start(exec, 1001)
  exec = engine.running(exec, 1002)
  exec = engine.finish(exec, { code = 0 }, 1005)
  engine.set_listener(nil)

  T.eq(events_seen, { "IgnitionStart", "IgnitionSuccess", "IgnitionExit" })
end)

T.it("acceptance: fallo emite Start, Failed y Exit en orden", function()
  local events_seen = {}
  engine.set_listener(function(exec)
    for _, t in ipairs(lifecycle.for_transition(exec)) do
      events_seen[#events_seen + 1] = t.name
    end
  end)

  local exec = engine.create { task_id = "run", command = "go test .", now = 1000 }
  exec = engine.start(exec, 1001)
  exec = engine.running(exec, 1002)
  exec = engine.finish(exec, { code = 1 }, 1005)
  engine.set_listener(nil)

  T.eq(events_seen, { "IgnitionStart", "IgnitionFailed", "IgnitionExit" })
end)

T.it("el módulo es Core puro (sin vim)", function()
  T.eq(type(lifecycle.data), "function")
  local ev = lifecycle.for_transition(build "success")
  T.truthy(ev[1].name, "descriptores sin side effects")
end)