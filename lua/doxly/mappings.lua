local config = require("doxly.config")

local M = {}

function M.setup()
    if config.options.mappings then
        if config.options.mappings.encrypt then
            vim.keymap.set("x", config.options.mappings.encrypt, ':DoxlyEnc<CR>',
                { desc = "[Doxly] encrypt selected text" })
        end
        if config.options.mappings.decrypt then
            vim.keymap.set("x", config.options.mappings.decrypt, ':DoxlyDec<CR>',
                { desc = "[Doxly] decrypt selected text" })
        end
    end
end

return M
