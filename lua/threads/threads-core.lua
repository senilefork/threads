local utils = require("threads.utils")

---@class Thread
---@field name string
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
	self.active_mark = nil
	return self
end
---@return nil
function Thread:add_mark()
	local filename, line_number, column = unpack(utils.get_curr_window_info())
	local line_text = vim.api.nvim_get_current_line()
	self.count = self.count + 1
	local mark = Mark.new(filename, line_number, column, line_text, self.count)
	self.active_mark = mark
	table.insert(self.marks, mark)
end

return Thread
