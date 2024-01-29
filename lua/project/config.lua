local M = {}

---@class ProjectOptions
M.defaults = {
  -- Manual mode doesn't automatically change your root directory, so you have
  -- the option to manually do so using `:ProjectRoot` command.
  manual_mode = false,

  -- Methods of detecting the root directory. **"lsp"** uses the native neovim
  -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
  -- order matters: if one is not detected, the other is used as fallback. You
  -- can also delete or rearangne the detection methods.
  detection_methods = { "lsp", "pattern" },

  -- All the patterns used to detect root dir, when **"pattern"** is in
  -- detection_methods
  patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },

  -- Table of lsp clients to ignore by name
  -- eg: { "efm", ... }
  ignore_lsp = {},

  -- Don't calculate root dir on specific directories
  -- Ex: { "~/.cargo/*", ... }
  exclude_dirs = {},

  -- Show hidden files in telescope
  show_hidden = false,

  -- When set to false, you will get a message when project.nvim changes your
  -- directory.
  silent_chdir = true,

  -- What scope to change the directory, valid options are
  -- * global (default)
  -- * tab
  -- * win
  scope_chdir = "global",

  -- custom chdir function to use (optional)
  -- if this method returns `true`, then the default method will not be used
  -- (and obviates `silent_chdir` and `scope_chdir`). return `false` to
  -- fall back to the default method
  -- signature: function(path, method) -> bool
  custom_chdir_fn = nil,

  -- Function to get current directory
  -- This is used by `find_pattern_root` to get the directory of the current buffer. For buffers like oil.nvim, the
  -- usual vim.fn.expand will not work, since the it returns a URI instead of a path. For buffers like this, you can
  -- customize how project.nvim obtains the current dir.
  pattern_get_current_dir_fn = function()
    return vim.fn.expand("%:p:h", true)
  end,

  -- Path where project.nvim will store the project history for use in
  -- telescope
  datapath = vim.fn.stdpath("data"),
}

---@type ProjectOptions
M.options = {}

M.setup = function(options)
  M.options = vim.tbl_deep_extend("force", M.defaults, options or {})

  local glob = require("project.utils.globtopattern")
  local home = vim.fn.expand("~")
  M.options.exclude_dirs = vim.tbl_map(function(pattern)
    if vim.startswith(pattern, "~/") then
      pattern = home .. "/" .. pattern:sub(3, #pattern)
    end
    return glob.globtopattern(pattern)
  end, M.options.exclude_dirs)

  vim.opt.autochdir = false -- implicitly unset autochdir

  require("project.utils.path").init()
  require("project.project").init()
end

return M
