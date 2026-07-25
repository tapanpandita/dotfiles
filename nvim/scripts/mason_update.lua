-- Reinstall every mason-managed package at its latest version. Run headlessly
-- from bin/dev-update via `nvim -c 'luafile ...'` (it needs the plugins on the
-- runtimepath, so it can't be launched with `nvim -l`).
local reg = require("mason-registry")

local refreshed = false
reg.refresh(function() refreshed = true end)
vim.wait(30000, function() return refreshed end, 100)

local installed = reg.get_installed_packages()
if #installed == 0 then
    print("mason: nothing installed")
    return
end

local remaining = #installed
for _, pkg in ipairs(installed) do
    print("mason: updating " .. pkg.name)
    pkg:install():once("closed", function() remaining = remaining - 1 end)
end
vim.wait(600000, function() return remaining == 0 end, 500)
print("mason: " .. #installed .. " package(s) at latest")
