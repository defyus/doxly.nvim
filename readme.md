# Doxly.nvim 

Doxly.nvim provides GPG encryption with Base64 encoding. Securely encrypt your text with a password and get a single-line Base64 output that's easy to share and use.

## Prerequisites

- Neovim 0.8 or higher
- GPG (GNU Privacy Guard)
- Base64 command-line utility

## ✨ Features

- GPG Passphrase Encrytion 
- Single Line GPG Encrypted Base64 Output
- No passphrase cache (Don't forget your passphrase)

## ⚡️ Requirements

- Neovim >= 0.8.0
- Other dependencies
    - GPG
    - Base64
    - Bash

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "defyus/doxly.nvim",
    event = "VeryLazy",
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "defyus/doxly.nvim",
    config = function()
        require("doxly").setup({
            -- your configuration comes here
        })
    end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'defyus/doxly.nvim'
```

Then in your init.lua:

```lua
require("doxly").setup({
    -- your configuration comes here
})
```

## ⚙️ Configuration

Doxly.nvim comes with the following defaults:

```lua
{
    enabled = true,
    mappings = {
        encrypt = "<leader>en",
        decrypt = "<leader>dc"
    },
}
```
## 🚀 Usage

Explain how to use your plugin here.

## 🔍 Commands

1. Encrypt selected text:
   ```vim
   :'<,'>DoxlyEnc
   ```
   - Select text in visual mode
   - Run command
   - Prompts for password
   - Replaces selected text with encrypted, base64-encoded result

2. Decrypt selected text:
   ```vim
   :'<,'>DoxlyDec
   ```
   - Place cursor in buffer containing encrypted text
   - Run command
   - Prompts for password
   - Opens new split with decrypted content


## ⌨️ Mappings

Default mappings (can be disabled or changed in setup):

- `<leader>en` - Description of what this mapping does
- `<leader>dc` - Description of what this mapping does

## Security Notes

1. Passwords are never stored or saved
2. Memory is cleared after encryption/decryption
3. Temporary files are securely deleted
4. Uses GPG's symmetric encryption
5. All output is in Base64 format for easy sharing

## Tips

1. The encrypted output is a single line of Base64 text, making it easy to:
   - Copy/paste into emails
   - Share through messaging apps
   - Store in configuration files

2. When sharing encrypted content:
   - Share the encrypted text through any medium
   - Share the password through a different, secure channel
   - The recipient can use the same plugin to decrypt

3. For Visual Mode:
   - `v` (character-wise)
   - `V` (line-wise)
   - `ctrl-v` (block-wise)
   All work with the encryption command

## Troubleshooting

1. If encryption fails:
   - Check if GPG is installed: `gpg --version`
   - Check if base64 is available: `base64 --version`
   - Ensure you have write permissions in the current directory

2. If decryption fails:
   - Verify you're using the correct password
   - Ensure the encrypted text is complete and unmodified
   - Check that the text is properly base64-encoded

## 💡 Contributing

Contributions are welcome! Feel free to open issues and PRs.

## 📜 License

MIT

### v1.0.0
- Initial release
- Base64 single-line output
- Visual mode support
- Secure password handling
