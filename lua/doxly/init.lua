local M = {}

---@type Config
M.config = require("doxly.config")
M.utils = require("doxly.utils")

---@param opts? Config
function M.setup(opts)
    -- Load config
    M.config.setup(opts)

    -- Safety check
    if not M.config.options.enabled then
        return
    end

    -- Setup components
    require("doxly.commands").setup()
    require("doxly.mappings").setup()

    -- Set up autocommands if needed
    local group = vim.api.nvim_create_augroup("Doxly", { clear = true })

    vim.api.nvim_create_autocmd({ "FileType" }, {
        group = group,
        pattern = "*",
        callback = function()
            -- Add your autocommands here
        end,
    })
end

return M
