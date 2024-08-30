local prev_line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
local prev_bufnr = vim.api.nvim_get_current_buf()
local set = false

local virtual_text = true
local message_area = true
local signs = false

local severity = {
  { texthl = "LspDiagnosticsVirtualTextError",       sign = "DiagnosticSignError" },
  { texthl = "LspDiagnosticsVirtualTextWarning",     sign = "DiagnosticSignWarning" },
  { texthl = "LspDiagnosticsVirtualTextInformation", sign = "DiagnosticSignInfo" },
  { texthl = "LspDiagnosticsVirtualTextHint",        sign = "DiagnosticSignHint" },
}

local function setup(parameters)
  parameters = parameters or {}

  message_area = parameters.message_area == nil and message_area or parameters.message_area
  virtual_text = parameters.virtual_text == nil and virtual_text or parameters.virtual_text
  signs = parameters.signs == nil and signs or parameters.signs
end

local function clear(bufnr)
  if not set then
    return
  end

  if message_area then
    print(" ")
  end

  if virtual_text then
    local opts = {
      id = 1,
      virt_text = { { "", "" } },
      virt_text_pos = "eol",
    }
    pcall(vim.api.nvim_buf_set_extmark, bufnr, 1, prev_line_nr, 0, opts)
  end
  set = false
end

local function printDiagnostics(bufnr, line_nr)
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local line_diagnostics = vim.diagnostic.get(0, { lnum = line_number - 1 })

  prev_bufnr = bufnr
  prev_line_nr = line_nr

  if vim.tbl_isempty(line_diagnostics) then
    clear(bufnr)
    return
  end

  if set then
    return
  end
  prev_bufnr = bufnr
  set = true

  local diagnostic_message = ""
  -- local diagnostic = line_diagnostics[#line_diagnostics]
  local diagnostic = line_diagnostics[1]
  local text = vim.fn.sign_getdefined(severity[diagnostic.severity].sign)

  local count = 0
  for _ in pairs(text) do
    count = count + 1
  end
  if count >= 1 then
    text = text[1].text
  else
    text = ""
  end

  diagnostic_message = diagnostic_message .. string.format("%s%s", signs and text or "", diagnostic.message or "")

  if message_area then
    print(diagnostic_message)
  end

  if virtual_text then
    local opts = {
      id = 1,
      virt_text = { { diagnostic_message, severity[diagnostic.severity].texthl } },
      virt_text_pos = "eol",
    }
    pcall(vim.api.nvim_buf_set_extmark, bufnr, 1, line_nr, 0, opts)
  end
end

local augroup = vim.api.nvim_create_augroup("simple-diagnostics", { clear = true })

vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
  pattern = "*.*",
  group = augroup,
  callback = function()
    printDiagnostics(vim.api.nvim_get_current_buf(), vim.api.nvim_win_get_cursor(0)[1] - 1)
  end,
})

vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufEnter" }, {
  pattern = "*.*",
  group = augroup,
  callback = function()
    clear(prev_bufnr)
  end,
})

return {
  setup = setup,
}
