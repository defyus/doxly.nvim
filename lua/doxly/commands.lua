local utils = require("doxly.utils")

local M = {}

function M.setup()
    vim.api.nvim_create_user_command("DoxlyDec", function(opts)
        local start_line, end_line = opts.line1, opts.line2
        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

        local password = utils.get_password("Enter decryption password: ")

        if not password then
            vim.notify("No password provided", vim.log.levels.WARN)
            return
        end

        -- Get current buffer content
        local encrypted = table.concat(lines, "\n")

        local decrypted_value = utils.decrypt(encrypted, password)

        if decrypted_value == nil then
            vim.notify("Unable to decrypt value", vim.log.levels.WARN)
        end

        -- Create new buffer with decrypted content
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, decrypted_value)

        vim.cmd("vsplit")
        vim.api.nvim_win_set_buf(0, buf)
    end, {
        range = true
    })

    -- Version that works with visual selection
    vim.api.nvim_create_user_command("DoxlyEnc", function(opts)
        -- Get the visual selection
        local start_line, end_line = opts.line1, opts.line2
        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
        local message = table.concat(lines, "\n")

        -- Get password
        local password = utils.get_password("Enter encryption password: ")

        if not password then
            vim.notify("No password provided", vim.log.levels.WARN)
            return
        end

        local encrypted_value = utils.encrypt(message, password)

        vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, encrypted_value)
    end, {
        range = true
    })
end

return M
