require("threads.ui")

M = {}

M.opts = { add_mark = "bb", open_window = "oo" }

---@class Thread
---@field thread_name string
---@field count number
---@field marks Mark[]
---@field add_mark function

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
	return self
end
---@return nil
function Thread:add_mark()
	local filename = vim.api.nvim_buf_get_name(0)
	local line_text = vim.api.nvim_get_current_line()
	self.count = self.count + 1
	local mark = Mark.new(filename, 1, 1, line_text, self.count)
	table.insert(self.marks, mark)
end

local create_thread_session = function(name)
	local thread = Thread.new(name)
	vim.keymap.set("n", "<leader>" .. M.opts.add_mark, function()
		thread:add_mark()
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
