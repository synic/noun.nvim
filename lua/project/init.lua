local config = require("project.config")
local project = require("project.project")
local history = require("project.utils.history")
local M = {}

M.setup = config.setup
M.get_recent_projects = history.get_recent_projects
M.get_project_root = project.get_project_root

return M
