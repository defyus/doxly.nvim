---@class Mappings
---@field encrypt string
---@field decrypt string

---@class Config
---@field enabled boolean
---@field mappings Mappings

local M = {}

M.defaults = {
    enabled = true,
    mappings = {
        encrypt = "<leader>en",
        decrypt = "<leader>dc"
    }
}

M.options = {}

---@param opts? Config
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
