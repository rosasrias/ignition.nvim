if vim.g.loaded_ignition then
  return
end
vim.g.loaded_ignition = true

vim.api.nvim_create_user_command("IgnitionRun", function()
  require("ignition").build_run()
end, { desc = "Ignition: selector de build/run" })

vim.api.nvim_create_user_command("IgnitionRunLast", function()
  require("ignition").run_last()
end, { desc = "Ignition: repetir última ejecución" })

vim.api.nvim_create_user_command("IgnitionRunHistory", function()
  require("ignition").run_history()
end, { desc = "Ignition: historial de ejecuciones" })

vim.api.nvim_create_user_command("IgnitionRunStop", function()
  require("ignition").stop()
end, { desc = "Ignition: detener la ejecución en marcha" })

vim.api.nvim_create_user_command("IgnitionRunRestart", function()
  require("ignition").restart()
end, { desc = "Ignition: detener y repetir la última ejecución" })

vim.api.nvim_create_user_command("IgnitionRunTask", function(args)
  require("ignition").run_task(args.fargs[1] or "")
end, { nargs = 1, desc = "Ignition: ejecuta una task de workflow (por nombre)" })
