# 🗃️ noun.nvim

**noun.nvim** is an all in one neovim plugin written in lua that provides
superior project management.

This is a fork of https://github.com/ahmedkhalf/project.nvim, which appears to
be a dead project. There are quite a few unanswered issues and pull requests. I
decided to hard fork it because I wanted to take some big liberties, like
changing the repo name and the main module name so they match, which makes the
whole thing work better with modern package managers like lazy.nvim.

## :exclamation: WARNING - BREAKING CHANGE FROM project.nvim!

As mentioned above, I have changed the repository name and the module name to
"noun", which means that you'll want to replace all occurrences in your config
from `project_nvim` to `noun`, and pass `noun` to `telescope.load_extension`
instead of `projects` (see below)

![Telescope Integration](https://user-images.githubusercontent.com/36672196/129409509-62340f10-4dd0-4c1a-9252-8bfedf2a9945.png)

## ⚡ Requirements

- Neovim >= 0.5.0

## ✨ Features

- Automagically cd to project directory using nvim lsp
  - Dependency free, does not rely on lspconfig
- If no lsp then uses pattern matching to cd to root directory
- Telescope integration `:Telescope projects`
  - Access your recently opened projects from telescope!
  - Asynchronous file io so it will not slow down vim when reading the history
    file on startup.
- ~~Nvim-tree.lua support/integration~~
  - Please add the following to your config instead:
    ```vim
    " Vim Script
    lua << EOF
    require("nvim-tree").setup({
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true
      },
    })
    EOF
    ```
    ```lua
    -- lua
    require("nvim-tree").setup({
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true
      },
    })
    ```

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ "synic/noun.nvim", config = true }

-- or as a dependency to `telescope`

{
  "nvim-telescope/telescope.nvim",
  dependencies = { { "synic/noun.nvim", config = true } },
},
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
" Vim Script
Plug 'synic/noun.nvim'

lua << EOF
  require("noun").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
EOF
```

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use {
  "synic/noun.nvim",
  config = function()
    require("noun").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  end
}
```

## ⚙️ Configuration

**noun.nvim** comes with the following defaults:

```lua
{
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
  scope_chdir = 'global',

  -- Optional custom callback function to be called when a project is selected.
  -- if this function returns "true", then the default method (which is to
  -- change the directory) will not be executed.
  project_selected_callback_fn = nil,

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
```

Even if you are pleased with the defaults, please note that `setup {}` must be
called for the plugin to start.

### Pattern Matching

**project.nvim**'s pattern engine uses the same expressions as vim-rooter, but
for your convenience, I will copy paste them here:

To specify the root is a certain directory, prefix it with `=`.

```lua
patterns = { "=src" }
```

To specify the root has a certain directory or file (which may be a glob), just
give the name:

```lua
patterns = { ".git", "Makefile", "*.sln", "build/env.sh" }
```

To specify the root has a certain directory as an ancestor (useful for
excluding directories), prefix it with `^`:

```lua
patterns = { "^fixtures" }
```

To specify the root has a certain directory as its direct ancestor / parent
(useful when you put working projects in a common directory), prefix it with
`>`:

```lua
patterns = { ">Latex" }
```

To exclude a pattern, prefix it with `!`.

```lua
patterns = { "!.git/worktrees", "!=extras", "!^fixtures", "!build/env.sh" }
```

List your exclusions before the patterns you do want.

### Telescope Integration

To enable telescope integration:
```lua
require('telescope').load_extension('noun')
```

#### Telescope Projects Picker
To use the projects picker
```lua
require'telescope'.extensions.noun.projects{}
```

#### Telescope mappings

**project.nvim** comes with the following mappings:

| Normal mode | Insert mode | Action                     |
| ----------- | ----------- | -------------------------- |
| f           | \<c-f\>     | find\_project\_files       |
| b           | \<c-b\>     | browse\_project\_files     |
| d           | \<c-d\>     | delete\_project            |
| s           | \<c-s\>     | search\_in\_project\_files |
| r           | \<c-r\>     | recent\_project\_files     |
| w           | \<c-w\>     | change\_working\_directory |

## API

Get a list of recent projects:

```lua
local noun = require("noun")
local recent_projects = noun.get_recent_projects()

print(vim.inspect(recent_projects))
```
#### Prints: { "/path/to/a/project", "/path/to/another-project" }

Get project root path:

```lua
local noun = require("noun")
local project_path, method = noun.get_project_root()

print(project_path, method)
```
#### Prints: "/path/to/a/project" "pattern .git"

## 🤝 Contributing

- All pull requests are welcome.
- If you encounter bugs please open an issue.
