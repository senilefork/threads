local session = require("threads.session")
local ui = require("threads.general_ui")
local M = {}

-- create data directory for threads if it does not exist
-- create_data_dir() (from data.lua)

M.setup = function(opts)
	--- extend user opts
	vim.api.nvim_create_user_command("Thread", session.create_new_thread_session, { nargs = 1 })
	vim.keymap.set("n", "<leader>oo", function()
		popup = ui.new()
		popup:open_threads_window()
	end, { noremap = true }) 
end
return M

--- TODO ---
--- improve ui on telescope windows
--- have preview selection change active mark of current thread
--- may need to reconsider some data structure creation
--- create threads data dir if it doesn't exist on startup
