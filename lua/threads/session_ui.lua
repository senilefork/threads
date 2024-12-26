local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local previewer = require('telescope.config').values.grep_previewer


local Thread = require("threads.threads-core")
local data = require("threads.data")
local move = require("threads.move")

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

---@return nil
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
				move.update_window(selection.filename)
				vim.api.nvim_win_set_cursor(0, { selection.value.line_number, selection.value.column })
			end)
			return true
		end,
	}):find()
end

return PopUp
