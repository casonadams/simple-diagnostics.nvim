local set = false
local show_virtual_text = true
local show_message_area = true
local prev_line_nr = 0

local severity = {
  [1] = "LspDiagnosticsVirtualTextError",
  [2] = "LspDiagnosticsVirtualTextWarning",
  [3] = "LspDiagnosticsVirtualTextInformation",
  [4] = "LspDiagnosticsVirtualTextHint",
}

local function setup(parameters)
  parameters = parameters or {}
  if parameters.show_message_area == nil then
    show_message_area = false
  else
    show_message_area = parameters.show_message_area
  end

  if parameters.show_virtual_text == nil then
    show_virtual_text = true
  else
    show_virtual_text = parameters.show_virtual_text
  end
end

local function clear()
  if not set then return end

  local bufnr = 0
  if show_message_area then
    print(" ")
  end
  if show_virtual_text then
    local opts = {
      -- end_line = 10,
      id = 1,
      virt_text = { { "", "" } },
      virt_text_pos = 'eol',
      -- virt_text_win_col = 20,
    }
    vim.api.nvim_buf_set_extmark(bufnr, 1, prev_line_nr, 10, opts)
  end
  set = false
end

local function printDiagnostics(line_nr)
  local bufnr = 0
  local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, line_nr)

  if vim.tbl_isempty(line_diagnostics) then
    clear()
    return
  end

  if set then return end

  local diagnostic_message = ""
  local diagnostic_severity = ""

  for _, diagnostic in ipairs(line_diagnostics) do
    diagnostic_message = diagnostic_message .. string.format("%s", diagnostic.message or "")
    diagnostic_severity = diagnostic.severity
    -- break on first error
    break
  end

  if show_message_area then
    print(diagnostic_message)
  end

  if show_virtual_text then
    local opts = {
      id = 1,
      virt_text = { { diagnostic_message, severity[diagnostic_severity] } },
      virt_text_pos = 'eol',
    }
    vim.api.nvim_buf_set_extmark(bufnr, 1, line_nr, 10, opts)
  end
  set = true
end

local augroup = vim.api.nvim_create_augroup('simple-diagnostics', { clear = true })

vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
  pattern = '*.*',
  group = augroup,
  callback = function() printDiagnostics(vim.api.nvim_win_get_cursor(0)[1] - 1) end
})

vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufEnter' }, {
  pattern = '*.*',
  group = augroup,
  callback = function() clear() end
})

return {
  setup = setup,
}
