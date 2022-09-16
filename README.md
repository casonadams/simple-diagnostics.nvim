# simple-diagnostics

simple-diagnostics removes the noise of every line error,
and only show the current line error.

Options include showing error in MsgArea, and or as virtual text

Requires [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

Disable `vitural_text`

- neovim

```lua
vim.diagnostic.config({
  virtual_text = false
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
      virtual_text = true,
      message_area = true,
      signs = true,
    })
  end,
})
```

## define sign symbols

```lua
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = nil })
end
```
