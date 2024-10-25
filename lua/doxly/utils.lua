local M = {}

function M.executable_exists(executable)
    return vim.fn.executable(executable) == 1
end

---@param msg string
---@param level? number
function M.notify(msg, level)
    vim.notify(string.format("[doxly] %s", msg), level or vim.log.levels.INFO)
end

---@param msg string
function M.error(msg)
    M.notify(msg, vim.log.levels.ERROR)
end

---@class InputOptions
---@field prompt string
---@field default? string
---@field completion? string
---@field hidden boolean

---@class JobOptions
---@field args? string[]
---@field cwd? string
---@field env? table<string,string>
---@field on_success? fun(output: string[])
---@field on_error? fun(error: string[])
---@field show_errors? boolean
---@field silent? boolean

---Run a command asynchronously
---@param cmd string
---@param opts? JobOptions
---@return integer|nil job_id
function M.run_async(cmd, opts)
    opts = opts or {}

    if not M.executable_exists(cmd) then
        M.error(string.format("Executable '%s' not found", cmd))
        return nil
    end

    local stdout = {}
    local stderr = {}

    local job_id = vim.fn.jobstart({
        cmd,
        unpack(opts.args or {})
    }, {
        cwd = opts.cwd,
        env = opts.env,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data then
                vim.list_extend(stdout, data)
            end
        end,
        on_stderr = function(_, data)
            if data then
                vim.list_extend(stderr, data)
            end
        end,
        on_exit = function(_, exit_code)
            -- Remove empty lines
            stdout = vim.tbl_filter(function(line)
                return line ~= ""
            end, stdout)

            stderr = vim.tbl_filter(function(line)
                return line ~= ""
            end, stderr)

            if exit_code == 0 then
                if opts.on_success then
                    opts.on_success(stdout)
                elseif not opts.silent then
                    M.notify(table.concat(stdout, "\n"))
                end
            else
                if opts.on_error then
                    opts.on_error(stderr)
                elseif opts.show_errors ~= false then
                    M.error(table.concat(stderr, "\n"))
                end
            end
        end
    })

    return job_id
end

---Run a command synchronously
---@param cmd string
---@param opts? JobOptions
---@return string[] stdout
---@return string[] stderr
---@return number exit_code
function M.run_sync(cmd, opts)
    opts = opts or {}

    if not M.executable_exists(cmd) then
        M.error(string.format("Executable '%s' not found", cmd))
        return {}, {}, -1
    end

    local command = { cmd }
    if opts.args then
        vim.list_extend(command, opts.args)
    end

    local output = vim.fn.system(command)
    local exit_code = vim.v.shell_error

    local stdout = {}
    local stderr = {}

    if exit_code == 0 then
        stdout = vim.split(output, "\n")
        if opts.on_success then
            opts.on_success(stdout)
        elseif not opts.silent then
            M.notify(output)
        end
    else
        stderr = vim.split(output, "\n")
        if opts.on_error then
            opts.on_error(stderr)
        elseif opts.show_errors ~= false then
            M.error(output)
        end
    end

    return stdout, stderr, exit_code
end

---Get input from the user
---@param opts InputOptions
---@return string|nil
function M.get_input(opts)
    local input = vim.fn.input({
        prompt = opts.prompt,
        default = opts.default or '',
        completion = opts.completion,
        cancelreturn = nil,
    })

    -- Clear the command line
    vim.cmd('redraw')

    if input == nil or input == '' then
        return nil
    end

    return input
end

---Get password input (hidden)
---@param prompt string
---@return string|nil
function M.get_password(prompt)
    -- Save current settings
    local old_icm = vim.o.ignorecase
    local old_scl = vim.o.showcmd
    local old_sh = vim.o.showmode

    -- Configure for secure input
    vim.opt.ignorecase = false
    vim.opt.showcmd = false
    vim.opt.showmode = false

    -- Use inputsecret() for password input
    local password = vim.fn.inputsecret(prompt)

    -- Clear the command line
    vim.cmd('redraw')

    -- Restore settings
    vim.opt.ignorecase = old_icm
    vim.opt.showcmd = old_scl
    vim.opt.showmode = old_sh

    if password == nil or password == '' then
        return nil
    end

    return password
end

---Encrupt Function
---@param input string|nil
---@param password string|nil
---@return string[]|nil
function M.encrypt(input, password)
    local temp_file = os.tmpname()
    local f = io.open(temp_file, "w")

    if f == nil then
        vim.notify("temp file creation failed ", vim.log.levels.ERROR)
    end

    if input == '' or password == '' then
        vim.notify("input and password is required", vim.log.levels.ERROR)
    end

    f:write(input)
    f:close()

    local stdout = M.run_sync("bash", {
        args = {
            "-c",
            string.format(
                'cat "%s" | gpg --symmetric --armor --batch --yes --passphrase "%s" | base64 -w 0',
                temp_file,
                password
            )
        },
        silent = true
    })

    os.remove(temp_file)

    password = nil
    input = nil

    collectgarbage()

    vim.notify("Selection encrypted and encoded successfully!")

    return stdout
end

---Decrypt Function
---@param input string|nil
---@param password string|nil
---@return string[]|nil
function M.decrypt(input, password)
    -- Create temporary file
    vim.notify(input, vim.log.levels.ERROR)
    local temp_file = os.tmpname()
    local f = io.open(temp_file, "w")

    if f == nil then
        vim.notify("Temp file creation failed ", vim.log.levels.ERROR)
    end

    if input == '' or password == '' then
        vim.notify("input and password is required", vim.log.levels.ERROR)
    end

    f:write(input)
    f:close()

    function CB(value)
        return value
    end

    local stdout = M.run_sync("bash", {
        args = {
            "-c",
            string.format(
                'cat "%s" | base64 -d | gpg --decrypt --batch --yes --passphrase "%s" 2>/dev/null',
                temp_file,
                password
            )
        },
        silent = true
    })

    os.remove(temp_file)

    password = nil

    collectgarbage()

    vim.notify("Message decrypted successfully!")

    return stdout
end

return M
