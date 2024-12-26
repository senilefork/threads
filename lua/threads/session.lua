local Thread = require("threads.threads-core")
local PopUp = require("threads.session_ui")
local move = require("threads.move")
local data = require("threads.data")

local M = {}

M.opts = { add_mark = "am", open_previewer = "op", move_backward = "bb", move_forward = "mf", save_thread = "st" }

function M.create_thread_session(thread)
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

	vim.keymap.set("n", "<leader>" .. M.opts.open_previewer, function()
		popUp:open_previewer(thread)
	end, { noremap = true })

	vim.keymap.set("n", "<leader>" .. M.opts.save_thread, function()
		data.write_thread_data(thread)
	end, { noremap = true })
end

function M.load_thread_session(thread_name)
	local thread = Thread.new(thread_name)
	local thread_data = data.get_thread(thread_name)
	thread:load(thread_data)
	M.create_thread_session(thread)
end

function M.create_new_thread_session(command)
	local thread = Thread.new(command.args)
	data.add_thread(thread.name)
	M.create_thread_session(thread)
end

return M
