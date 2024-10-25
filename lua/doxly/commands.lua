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
    vim.api.nvim_create_user_command("DoxlyEnc", function(_opts)
        -- Get the visual selection
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")

        local start_line, start_col = start_pos[2], start_pos[3]
        local end_line, end_col = end_pos[2], end_pos[3]
        -- Get the selected text
        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

        if #lines == 0 then return end

        local message = ""

        if start_line == end_line then
            -- Selection is on a single line
            message = string.sub(lines[1], start_col, end_col)
        else
            -- Selection spans multiple lines
            local result = {}
            -- First line from start column to end
            table.insert(result, string.sub(lines[1], start_col))
            -- Middle lines (if any)
            for i = 2, #lines - 1 do
                table.insert(result, lines[i])
            end
            -- Last line from start to end column
            table.insert(result, string.sub(lines[#lines], 1, end_col))

            message = table.concat(result, "\n")
        end

        -- Get password
        local password = utils.get_password("Enter encryption password: ")

        if not password then
            vim.notify("No password provided", vim.log.levels.WARN)
            return
        end

        local encrypted_value = utils.encrypt(message, password)

        if encrypted_value == nil or encrypted_value[1] == nil then
            vim.notify("Unable to encrypt value", vim.log.levels.WARN)
        end

        if #encrypted_value > 0 then
            local encrypted_text = encrypted_value[1] -- base64 is single line

            -- Get the current line content
            local current_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

            if start_line == end_line then
                -- Single line replacement
                local line = current_lines[1]
                local new_line = string.sub(line, 1, start_col - 1) ..
                    encrypted_text ..
                    string.sub(line, end_col + 1)
                vim.api.nvim_buf_set_lines(0, start_line - 1, start_line, false, { new_line })
            else
                -- Multiline replacement
                -- First line
                local first_line = current_lines[1]
                current_lines[1] = string.sub(first_line, 1, start_col - 1) .. encrypted_text

                -- Last line
                local last_line = current_lines[#current_lines]
                current_lines[1] = current_lines[1] .. string.sub(last_line, end_col + 1)

                -- Replace all lines with our single line containing the encrypted text
                vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, { current_lines[1] })
            end

            -- Position cursor at the start of replaced text
            vim.api.nvim_win_set_cursor(0, { start_line, start_col - 1 })
        end
    end, {
        range = true
    })
end

return M
