if vim.fn.has("nvim-0.8") == 0 then
    vim.api.nvim_err_writeln("Doxly requires at least Neovim 0.8")
    return
end

if vim.g.loaded_myplugin == 1 then
    return
end
vim.g.loaded_myplugin = 1
