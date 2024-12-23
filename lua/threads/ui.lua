local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local previewer = require('telescope.config').values.grep_previewer


local Thread = require("threads.threads-core")

---@class PopUp
---@field buf number|nil
---@field win number|nil
---@field open_window function

local PopUp = {}
PopUp.__index = PopUp

---@return  PopUp
function PopUp.new()
	local self = setmetatable({}, PopUp)
	self.buf = nil
	self.win = nil
	return self
end

local function get_pop_up_opts()
	local curr_win_id = vim.api.nvim_get_current_win()
	local curr_win_width = vim.api.nvim_win_get_width(curr_win_id)
	local curr_win_height = vim.api.nvim_win_get_height(curr_win_id)

	-- calculate our floating window size
	local pop_up_height = math.ceil(curr_win_height * 0.8 - 4)
	local pop_up_width = math.ceil(curr_win_width * 0.8)

	-- and its starting position
	local row = math.ceil((curr_win_height - pop_up_height) / 2 - 1)
	local col = math.ceil((curr_win_width - pop_up_width) / 2)

	-- set some options
	local opts = {
		style = "minimal",
		border = "rounded",
		relative = "editor",
		width = pop_up_width,
		height = pop_up_height,
		row = row,
		col = col,
		title = "...Threadsss...",
		title_pos = "center",
	}
	return opts
end

---@return nil
function PopUp:open_window(thread)
	self.buf = vim.api.nvim_create_buf(false, true)
	local opts = get_pop_up_opts()
	self.win = vim.api.nvim_open_win(self.buf, true, opts)

	local text_lines = {}
	for _, mark in ipairs(thread.marks) do
		table.insert(text_lines, mark.filename)
		table.insert(text_lines, mark.text)
	end
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, text_lines)
end

function PopUp:open_previewer(thread)
	opts = opts or {}
	pickers.new(opts, {
		prompt_title = 'marks',
		finder = finders.new_table {
		      results = thread.marks,
		      entry_maker = function(entry)
			return {
			  value = entry,
			  display = entry.filename,
			  ordinal = tostring(entry.thread_index),
			  filename = entry.filename,
		          lnum = entry.line_number,
			}
		      end
		    },
		sorter = conf.generic_sorter(opts),
		previewer = previewer(opts),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				vim.api.nvim_put({ selection.display }, "", false, true)
			end)
			return true
		end,
	}):find()
end

return PopUp
