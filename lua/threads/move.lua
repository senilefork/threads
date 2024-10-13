local utils = require("threads.utils")

local M = {}

function M.is_on_last_mark(mark, window_info)
	local filename, line_number, column = unpack(window_info)
	if mark.filename == filename and mark.line_number == line_number and mark.column == column then
		return true
	else
		return false
	end
end

function M.update_window(filename)
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

function M.determine_pos_and_update(thread, new_mark)
	local curr_window_info = utils.get_curr_window_info()
	local curr_filename, _, _ = unpack(curr_window_info)
	local active_mark = thread.active_mark
	if M.is_on_last_mark(active_mark, curr_window_info) == true then
		local filename = new_mark.filename
		if filename ~= curr_filename then
			M.update_window(filename)
		end
		vim.api.nvim_win_set_cursor(0, { new_mark.line_number, new_mark.column })
		thread.active_mark = new_mark
	else
		if curr_filename == active_mark.filename then
			vim.api.nvim_win_set_cursor(0, { active_mark.line_number, active_mark.column })
		else
			M.update_window(active_mark.filename)
			vim.api.nvim_win_set_cursor(0, { active_mark.line_number, active_mark.column })
		end
	end
end

function M.move_forward(thread)
	local active_mark = thread.active_mark
	local active_mark_index = active_mark.thread_index
	local next_mark = nil
	if active_mark_index == #thread.marks then
		next_mark = thread.marks[1]
	else
		next_mark = thread.marks[active_mark_index + 1]
	end
	M.determine_pos_and_update(thread, next_mark)
end

function M.move_backward(thread)
	local active_mark = thread.active_mark
	local active_mark_index = active_mark.thread_index
	local prev_mark = nil
	if active_mark_index == 1 then
		prev_mark = thread.marks[#thread.marks]
	else
		prev_mark = thread.marks[active_mark_index - 1]
	end
	M.determine_pos_and_update(thread, prev_mark)
end

return M
