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

        -- Create temporary file
        local temp_file = os.tmpname()
        local f = io.open(temp_file, "w")
        f:write(encrypted)
        f:close()

        -- Decode base64 and decrypt
        utils.run_async("bash", {
            args = {
                "-c",
                string.format(
                    'cat "%s" | base64 -d | gpg --decrypt --batch --yes --passphrase "%s"',
                    temp_file,
                    password
                )
            },
            on_success = function(stdout_lines)
                -- Create new buffer with decrypted content
                local buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, stdout_lines)

                vim.cmd("vsplit")
                vim.api.nvim_win_set_buf(0, buf)

                -- Clean up
                os.remove(temp_file)
                password = nil
                collectgarbage()

                vim.notify("Message decrypted successfully!")
            end,
            on_error = function(error_lines)
                vim.notify("Decryption failed: " .. table.concat(error_lines, "\n"), vim.log.levels.ERROR)
                -- Clean up
                os.remove(temp_file)
                password = nil
                collectgarbage()
            end
        })
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

        -- Create temporary file for the message
        local temp_file = os.tmpname()
        local f = io.open(temp_file, "w")
        f:write(message)
        f:close()

        -- Encrypt and encode
        utils.run_async("bash", {
            args = {
                "-c",
                string.format(
                    'cat "%s" | gpg --symmetric --armor --batch --yes --passphrase "%s" | base64 -w 0',
                    temp_file,
                    password
                )
            },
            on_success = function(stdout_lines)
                -- Replace the selected text with encrypted content
                vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, stdout_lines)

                -- Clean up
                os.remove(temp_file)
                password = nil
                message = nil
                collectgarbage()

                vim.notify("Selection encrypted and encoded successfully!")
            end,
            on_error = function(error_lines)
                vim.notify("Operation failed: " .. table.concat(error_lines, "\n"), vim.log.levels.ERROR)
                -- Clean up
                os.remove(temp_file)
                password = nil
                message = nil
                collectgarbage()
            end
        })
    end, {
        range = true
    })
end

return M
