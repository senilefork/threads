local session = require("threads.session")
local M = {}

-- create data directory for threads if it does not exist
-- create_data_dir() (from data.lua)

M.setup = function(opts)
	--- extend user opts
	vim.api.nvim_create_user_command("Thread", session.create_new_thread_session, { nargs = 1 })
end
return M
