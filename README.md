# simple-diagnostics

Requires [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

## install with packer

```lua
use({"casonadams/simple-diagnostics.nvim"})
```

## setup

```lua
require('simple-diagnostics').setup({
  show_virtual_text = true,
  show_message_area = false,
})
```
