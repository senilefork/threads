local Thread = require("threads.threads-core")
local PopUp = require("threads.ui")
local move = require("threads.move")
local data = require("threads.data")
local M = {}

M.opts = { add_mark = "am", open_window = "oo", move_backward = "bb", move_forward = "mf", save_thread = "st" }

-- create data directory for threads if it does not exist
-- create_data_dir() (from data.lua)

local create_thread_session = function(command)
	local thread = Thread.new(command.args)
	data.add_thread(thread.name)

	vim.keymap.set("n", "<leader>" .. M.opts.add_mark, function()
		thread:add_mark()
	end, { noremap = true })

	vim.keymap.set("n", "<leader>" .. M.opts.move_backward, function()
		move.move_backward(thread)
	end, { noremap = true })

	vim.keymap.set("n", "<leader>" .. M.opts.move_forward, function()
		move.move_forward(thread)
	end, { noremap = true })

	local popUp = PopUp.new()
	vim.keymap.set("n", "<leader>" .. M.opts.open_window, function()
		popUp:open_window(thread)
	end, { noremap = true })

	vim.keymap.set("n", "<leader>" .. M.opts.save_thread, function()
		data.write_thread_data(thread)
	end, { noremap = true })
end

M.setup = function(opts)
	--- extend user opts
	vim.api.nvim_create_user_command("Thread", create_thread_session, { nargs = 1 })
end
return M
