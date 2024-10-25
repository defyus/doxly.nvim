local M = {}

local health = vim.health or require("health")

function M.check()
    health.start("doxly")

    if vim.fn.has("nvim-0.8.0") == 1 then
        health.ok("Neovim version >= 0.8.0")
    else
        health.error("Neovim version must be >= 0.8.0")
    end

    if vim.fn.executable("gpg") == 1 then
        health.ok("GPG executable found")
    else
        health.error("GPG executable not found")
    end

    if vim.fn.executable("bash") == 1 then
        health.ok("Bash executable found")
    else
        health.error("Bash executable not found")
    end

    if vim.fn.executable("base64") == 1 then
        health.ok("base64 executable found")
    else
        health.error("base64 executable not found")
    end
end

return M
