--- ### astronvim utilities
--
-- various utility functions to use within astronvim and user configurations.
--
-- this module can be loaded with `local utils = require "astronvim.utils"`
--
-- @module astronvim.utils
-- @copyright 2022
-- @license gnu general public license v3.0

local m = {}

--- merge extended options with a default table of options
---@param default? table the default table that you want to merge into
---@param opts? table the new options that should be merged with the default table
---@return table # the merged table
function m.extend_tbl(default, opts)
  opts = opts or {}
  return default and vim.tbl_deep_extend("force", default, opts) or opts
end

--- partially reload astronvim user settings. includes core vim options, mappings, and highlights. this is an experimental feature and may lead to instabilities until restart.
---@param quiet? boolean whether or not to notify on completion of reloading
---@return boolean # true if the reload was successful, false otherwise
function m.reload(quiet)
  local core_modules = { "astronvim.bootstrap", "astronvim.options", "astronvim.mappings" }
  local modules = vim.tbl_filter(function(module) return module:find "^user%." end, vim.tbl_keys(package.loaded))

  vim.tbl_map(require("plenary.reload").reload_module, vim.list_extend(modules, core_modules))

  local success = true
  for _, module in ipairs(core_modules) do
    local status_ok, fault = pcall(require, module)
    if not status_ok then
      vim.api.nvim_err_writeln("failed to load " .. module .. "\n\n" .. fault)
      success = false
    end
  end
  if not quiet then -- if not quiet, then notify of result
    if success then
      m.notify("astronvim successfully reloaded", vim.log.levels.info)
    else
      m.notify("error reloading astronvim...", vim.log.levels.error)
    end
  end
  vim.cmd.doautocmd "colorscheme"
  return success
end

--- insert one or more values into a list like table and maintain that you do not insert non-unique values (this modifies `lst`)
---@param lst any[]|nil the list like table that you want to insert into
---@param vals any|any[] either a list like table of values to be inserted or a single value to be inserted
---@return any[] # the modified list like table
function m.list_insert_unique(lst, vals)
  if not lst then lst = {} end
  assert(vim.tbl_islist(lst), "provided table is not a list like table")
  if not vim.tbl_islist(vals) then vals = { vals } end
  local added = {}
  vim.tbl_map(function(v) added[v] = true end, lst)
  for _, val in ipairs(vals) do
    if not added[val] then
      table.insert(lst, val)
      added[val] = true
    end
  end
  return lst
end

--- call function if a condition is met
---@param func function the function to run
---@param condition boolean # whether to run the function or not
---@return any|nil result # the result of the function running or nil
function m.conditional_func(func, condition, ...)
  -- if the condition is true or no condition is provided, evaluate the function with the rest of the parameters and return the result
  if condition and type(func) == "function" then return func(...) end
end

--- get an icon from `lspkind` if it is available and return it
---@param kind string the kind of icon in `lspkind` to retrieve
---@param padding? integer padding to add to the end of the icon
---@param no_fallback? boolean whether or not to disable fallback to text icon
---@return string icon
function m.get_icon(kind, padding, no_fallback)
  if not vim.g.icons_enabled and no_fallback then return "" end
  local icon_pack = vim.g.icons_enabled and "icons" or "text_icons"
  if not m[icon_pack] then
    m.icons = astronvim.user_opts("icons", require "astronvim.icons.nerd_font")
    m.text_icons = astronvim.user_opts("text_icons", require "astronvim.icons.text")
  end
  local icon = m[icon_pack] and m[icon_pack][kind]
  return icon and icon .. string.rep(" ", padding or 0) or ""
end

--- get highlight properties for a given highlight name
---@param name string the highlight group name
---@param fallback? table the fallback highlight properties
---@return table properties # the highlight group properties
function m.get_hlgroup(name, fallback)
  if vim.fn.hlexists(name) == 1 then
    local hl
    if vim.api.nvim_get_hl then -- check for new neovim 0.9 api
      hl = vim.api.nvim_get_hl(0, { name = name, link = false })
      if not hl.fg then hl.fg = "none" end
      if not hl.bg then hl.bg = "none" end
    else
      hl = vim.api.nvim_get_hl_by_name(name, vim.o.termguicolors)
      if not hl.foreground then hl.foreground = "none" end
      if not hl.background then hl.background = "none" end
      hl.fg, hl.bg = hl.foreground, hl.background
      hl.ctermfg, hl.ctermbg = hl.fg, hl.bg
      hl.sp = hl.special
    end
    return hl
  end
  return fallback or {}
end

--- serve a notification with a title of astronvim
---@param msg string the notification body
---@param type number|nil the type of the notification (:help vim.log.levels)
---@param opts? table the nvim-notify options to use (:help notify-options)
function m.notify(msg, type, opts)
  vim.schedule(function() vim.notify(msg, type, m.extend_tbl({ title = "astronvim" }, opts)) end)
end

--- trigger an astronvim user event
---@param event string the event name to be appended to astro
function m.event(event)
  vim.schedule(function() vim.api.nvim_exec_autocmds("user", { pattern = "astro" .. event, modeline = false }) end)
end

--- open a url under the cursor with the current operating system
---@param path string the path of the file to open with the system opener
function m.system_open(path)
  local cmd
  if vim.fn.has "win32" == 1 and vim.fn.executable "explorer" == 1 then
    cmd = { "cmd.exe", "/k", "explorer" }
  elseif vim.fn.has "unix" == 1 and vim.fn.executable "xdg-open" == 1 then
    cmd = { "xdg-open" }
  elseif (vim.fn.has "mac" == 1 or vim.fn.has "unix" == 1) and vim.fn.executable "open" == 1 then
    cmd = { "open" }
  end
  if not cmd then m.notify("available system opening tool not found!", vim.log.levels.error) end
  vim.fn.jobstart(vim.fn.extend(cmd, { path or vim.fn.expand "<cfile>" }), { detach = true })
end

--- toggle a user terminal if it exists, if not then create a new one and save it
---@param opts string|table a terminal command string or a table of options for terminal:new() (check toggleterm.nvim documentation for table format)
function m.toggle_term_cmd(opts)
  local terms = astronvim.user_terminals
  -- if a command string is provided, create a basic table for terminal:new() options
  if type(opts) == "string" then opts = { cmd = opts, hidden = true } end
  local num = vim.v.count > 0 and vim.v.count or 1
  -- if terminal doesn't exist yet, create it
  if not terms[opts.cmd] then terms[opts.cmd] = {} end
  if not terms[opts.cmd][num] then
    if not opts.count then opts.count = vim.tbl_count(terms) * 100 + num end
    if not opts.on_exit then opts.on_exit = function() terms[opts.cmd][num] = nil end end
    terms[opts.cmd][num] = require("toggleterm.terminal").terminal:new(opts)
  end
  -- toggle the terminal
  terms[opts.cmd][num]:toggle()
end

--- create a button entity to use with the alpha dashboard
---@param sc string the keybinding string to convert to a button
---@param txt string the explanation text of what the keybinding does
---@return table # a button entity table for an alpha configuration
function m.alpha_button(sc, txt)
  -- replace <leader> in shortcut text with ldr for nicer printing
  local sc_ = sc:gsub("%s", ""):gsub("ldr", "<leader>")
  -- if the leader is set, replace the text with the actual leader key for nicer printing
  if vim.g.mapleader then sc = sc:gsub("ldr", vim.g.mapleader == " " and "spc" or vim.g.mapleader) end
  -- return the button entity to display the correct text and send the correct keybinding on press
  return {
    type = "button",
    val = txt,
    on_press = function()
      local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
      vim.api.nvim_feedkeys(key, "normal", false)
    end,
    opts = {
      position = "center",
      text = txt,
      shortcut = sc,
      cursor = 5,
      width = 36,
      align_shortcut = "right",
      hl = "dashboardcenter",
      hl_shortcut = "dashboardshortcut",
    },
  }
end

--- check if a plugin is defined in lazy. useful with lazy loading when a plugin is not necessarily loaded yet
---@param plugin string the plugin to search for
---@return boolean available # whether the plugin is available
function m.is_available(plugin)
  local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
  return lazy_config_avail and lazy_config.plugins[plugin] ~= nil
end

--- resolve the options table for a given plugin with lazy
---@param plugin string the plugin to search for
---@return table opts # the plugin options
function m.plugin_opts(plugin)
  local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
  local lazy_plugin_avail, lazy_plugin = pcall(require, "lazy.core.plugin")
  local opts = {}
  if lazy_config_avail and lazy_plugin_avail then
    local spec = lazy_config.plugins[plugin]
    if spec then opts = lazy_plugin.values(spec, "opts") end
  end
  return opts
end

--- a helper function to wrap a module function to require a plugin before running
---@param plugin string the plugin to call `require("lazy").load` with
---@param module table the system module where the functions live (e.g. `vim.ui`)
---@param func_names string|string[] the functions to wrap in the given module (e.g. `{ "ui", "select }`)
function m.load_plugin_with_func(plugin, module, func_names)
  if type(func_names) == "string" then func_names = { func_names } end
  for _, func in ipairs(func_names) do
    local old_func = module[func]
    module[func] = function(...)
      module[func] = old_func
      require("lazy").load { plugins = { plugin } }
      module[func](...)
    end
  end
end

--- register queued which-key mappings
function m.which_key_register()
  if m.which_key_queue then
    local wk_avail, wk = pcall(require, "which-key")
    if wk_avail then
      for mode, registration in pairs(m.which_key_queue) do
        wk.register(registration, { mode = mode })
      end
      m.which_key_queue = nil
    end
  end
end

--- table based api for setting keybindings
---@param map_table table a nested table where the first key is the vim mode, the second key is the key to map, and the value is the function to set the mapping to
---@param base? table a base set of options to set on every keybinding
function m.set_mappings(map_table, base)
  -- iterate over the first keys for each mode
  base = base or {}
  for mode, maps in pairs(map_table) do
    -- iterate over each keybinding set in the current mode
    for keymap, options in pairs(maps) do
      -- build the options for the command accordingly
      if options then
        local cmd = options
        local keymap_opts = base
        if type(options) == "table" then
          cmd = options[1]
          keymap_opts = vim.tbl_deep_extend("force", keymap_opts, options)
          keymap_opts[1] = nil
        end
        if not cmd or keymap_opts.name then -- if which-key mapping, queue it
          if not m.which_key_queue then m.which_key_queue = {} end
          if not m.which_key_queue[mode] then m.which_key_queue[mode] = {} end
          m.which_key_queue[mode][keymap] = keymap_opts
        else -- if not which-key mapping, set it
          vim.keymap.set(mode, keymap, cmd, keymap_opts)
        end
      end
    end
  end
  if package.loaded["which-key"] then m.which_key_register() end -- if which-key is loaded already, register
end

--- regex used for matching a valid url/uri string
m.url_matcher =
"\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

--- delete the syntax matching rules for urls/uris if set
function m.delete_url_match()
  for _, match in ipairs(vim.fn.getmatches()) do
    if match.group == "highlighturl" then vim.fn.matchdelete(match.id) end
  end
end

--- add syntax matching rules for highlighting urls/uris
function m.set_url_match()
  m.delete_url_match()
  if vim.g.highlighturl_enabled then vim.fn.matchadd("highlighturl", m.url_matcher, 15) end
end

--- run a shell command and capture the output and if the command succeeded or failed
---@param cmd string the terminal command to execute
---@param show_error? boolean whether or not to show an unsuccessful command as an error to the user
---@return string|nil # the result of a successfully executed command or nil
function m.cmd(cmd, show_error)
  local wind32_cmd
  if vim.fn.has "win32" == 1 then wind32_cmd = { "cmd.exe", "/c", cmd } end
  local result = vim.fn.system(wind32_cmd or cmd)
  local success = vim.api.nvim_get_vvar "shell_error" == 0
  if not success and (show_error == nil or show_error) then
    vim.api.nvim_err_writeln("error running command: " .. cmd .. "\nerror message:\n" .. result)
  end
  return success and result:gsub("[\27\155][][()#;?%d]*[a-przcf-ntqry=><~]", "") or nil
end

return m
