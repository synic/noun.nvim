local config = require("noun.config")
local project = require("noun.project")
local history = require("noun.utils.history")
local M = {}

M.setup = config.setup
M.get_recent_projects = history.get_recent_projects
M.get_project_root = project.get_project_root

return M
