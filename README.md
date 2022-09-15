# simple-diagnostics

simple-diagnostics removes the noise of every line error,
and only show the current line error.

Options include showing error in MsgArea, and or as virtual text

Requires [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

Disable `vitural_text`

- neovim

```lua
vim.diagnostic.config({
  virtual_text = false,
  underline = true,
})
```
- LunarVim

```lua
lvim.lsp.diagnostics.virtual_text = false
```

## install with packer

```lua
use({"casonadams/simple-diagnostics.nvim",
  config = function()
    require("simple-diagnostics").setup({
      show_virtual_text = true,
      show_message_area = true,
    })
  end,
})
```
