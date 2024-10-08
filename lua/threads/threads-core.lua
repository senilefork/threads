local get_curr_window_info = require("threads.utils").get_curr_window_info
require("threads.ui")

M = {}

M.opts = { add_mark = "am", open_window = "oo", move_backward = "bb", move_forward = "mf" }

---@class Thread
---@field thread_name string
---@field count number
---@field marks Mark[]
---@field add_mark function
---@field last_navigated_mark Mark|nil

---@class Mark
---@field filename string
---@field line_number number
---@field column number
---@field text string
---@field thread_index number

local Mark = {}
Mark.__index = Mark

-- Mark contructor
---@return Mark
function Mark.new(filename, line_number, column, text, thread_index)
	local self = setmetatable({}, Mark)
	self.filename = filename
	self.line_number = line_number
	self.column = column
	self.text = text
	self.thread_index = thread_index
	return self
end

local Thread = {} -- set Thread to a table
Thread.__index = Thread -- set a metatable to support methods

-- Thread contstructor
---@return Thread
function Thread.new(thread_name)
	local self = setmetatable({}, Thread)
	self.name = thread_name
	self.count = 0
	self.marks = {}
	self.last_navigated_mark = nil
	return self
end
---@return nil
function Thread:add_mark()
	local filename, line_number, column = unpack(get_curr_window_info())
	local line_text = vim.api.nvim_get_current_line()
	self.count = self.count + 1
	local mark = Mark.new(filename, line_number, column, line_text, self.count)
	self.last_navigated_mark = mark
	table.insert(self.marks, mark)
end

------ Threads util functions --------

local is_on_last_mark = function(mark, window_info)
	local filename, line_number, column = unpack(window_info)
	if mark.filename == filename and mark.line_number == line_number and mark.column == column then
		return true
	else
		return false
	end
end

local update_window = function(filename)
	print("window updated to " .. filename)
	--- add code to switch buffer windows here
	local bufnr = vim.fn.bufnr(filename)
	if bufnr == -1 then -- must create a buffer!
		bufnr = vim.fn.bufadd(filename)
	end
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		vim.fn.bufload(bufnr)
		vim.api.nvim_set_option_value("buflisted", true, {
			buf = bufnr,
		})
	end
	vim.api.nvim_set_current_buf(bufnr)
end

local determine_pos_and_update = function(thread, mark)
	local curr_window_info = get_curr_window_info()
	local curr_filename, curr_line_number, curr_column = unpack(curr_window_info)
	local last_navigated_mark = thread.last_navigated_mark
	if is_on_last_mark(last_navigated_mark, curr_window_info) == true then
		local filename = mark.filename
		update_window(filename) --- to mark behind current mark
		thread.last_navigated_mark = mark
	else
		--- am on last file? if yes, just update cursor
		if curr_filename == last_navigated_mark.filename then
			vim.api.nvim_win_set_cursor(0, { last_navigated_mark.line_number, last_navigated_mark.column })
			thread.last_navigated_mark = mark
		else
			--- else im not on last mark, last file or last cursor so update everything to last mark
			update_window(last_navigated_mark.filename)
			vim.api.nvim_win_set_cursor(0, { last_navigated_mark.line_number, last_navigated_mark.column })
		end
	end
end

local move_forward = function(thread)
	local last_navigated_mark = thread.last_navigated_mark
	local last_navigated_index = last_navigated_mark.thread_index
	local next_mark = nil
	if last_navigated_index == #thread.marks then
		next_mark = thread.marks[1]
	else
		next_mark = thread.marks[last_navigated_index + 1]
	end
	determine_pos_and_update(thread, next_mark)
end

local move_backward = function(thread)
	-- TODO: bug fix. if i am on the last navigated page but not on the last cursor position, just
	-- update the cursor position
	local last_navigated_mark = thread.last_navigated_mark
	local last_navigated_index = last_navigated_mark.thread_index
	local prev_mark = nil
	if last_navigated_index == 1 then
		prev_mark = thread.marks[#thread.marks]
	else
		prev_mark = thread.marks[last_navigated_index - 1]
	end
	determine_pos_and_update(thread, prev_mark)
end

local create_thread_session = function(name)
	local thread = Thread.new(name)
	vim.keymap.set("n", "<leader>" .. M.opts.add_mark, function()
		thread:add_mark()
	end, { noremap = true })

	vim.keymap.set("n", "<leader>" .. M.opts.move_backward, function()
		move_backward(thread)
	end, { noremap = true })

	vim.keymap.set("n", "<leader>" .. M.opts.move_forward, function()
		move_forward(thread)
	end, { noremap = true })

	local popUp = PopUp.new()
	vim.keymap.set("n", "<leader>" .. M.opts.open_window, function()
		popUp:open_window(thread)
	end, { noremap = true })
end

M.setup = function(opts)
	--- extend user opts
	vim.api.nvim_create_user_command("Thread", create_thread_session, { nargs = 1 })
end
return M
