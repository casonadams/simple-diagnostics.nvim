local show_virtual_text = true
local show_message_area = true

local function setup(parameters)
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

local function PrintDiagnostics(opts, bufnr, line_nr, client_id)
  opts = opts or {}
  bufnr = bufnr or 0
  line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)

  local diagnostic_message = ""
  local diagnostic_severity = ""
  local severity = {
    [1] = "LspDiagnosticsVirtualTextError",
    [2] = "LspDiagnosticsVirtualTextWarning",
    [3] = "LspDiagnosticsVirtualTextInformation",
    [4] = "LspDiagnosticsVirtualTextHint",
  }

  local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics(
    bufnr,
    line_nr,
    opts,
    client_id
  )

  if vim.tbl_isempty(line_diagnostics) then
    return
  end

  for _, diagnostic in ipairs(line_diagnostics) do
    diagnostic_message = diagnostic_message ..
        string.format("%s", diagnostic.message or "")
    diagnostic_severity = diagnostic.severity
    -- break on first error
    break
  end

  if show_message_area then
    print(diagnostic_message) -- prints to MsgArea
  end

  if show_virtual_text then
    vim.api.nvim_buf_set_virtual_text(bufnr, 1, line_nr, { { diagnostic_message, severity[diagnostic_severity] } }, {})
  end
end

local function Clear(opts, bufnr, line_nr)
  opts = opts or {}
  bufnr = bufnr or 0
  line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)

  if show_message_area then
    print("      ") -- print to MsgArea
  end
  if show_virtual_text then
    vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)
  end
end

local augroup = vim.api.nvim_create_augroup('simple-diagnostics', { clear = true })

vim.api.nvim_create_autocmd({ 'CursorHold' }, {
  pattern = '*',
  group = augroup,
  callback = function() PrintDiagnostics() end
})

vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
  pattern = '*',
  group = augroup,
  callback = function() Clear() end
})

return {
  setup = setup,
}
