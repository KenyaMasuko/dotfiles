if vim.g.vscode then
	local opt = vim.opt
	opt.clipboard = 'unnamedplus' -- yankでクリップボードに
else
  for _, source in ipairs {
    "astronvim.bootstrap",
    "astronvim.options",
    "astronvim.lazy",
    "astronvim.autocmds",
    "astronvim.mappings",
  } do
    local status_ok, fault = pcall(require, source)
    if not status_ok then vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault) end
  end

  if astronvim.default_colorscheme then
    if not pcall(vim.cmd.colorscheme, astronvim.default_colorscheme) then
      require("astronvim.utils").notify(
        "Error setting up colorscheme: " .. astronvim.default_colorscheme,
        vim.log.levels.ERROR
      )
    end
  end

  require("astronvim.utils").conditional_func(astronvim.user_opts("polish", nil, false), true)


  -- Copilot
  -- TODO: ファイル分割したい
  vim.g.copilot_no_tab_map = true
  vim.api.nvim_set_keymap("i", "<C-i>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
end
