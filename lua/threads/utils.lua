local M = {}
M.get_curr_window_info = function()
	local filename = vim.api.nvim_buf_get_name(0)
	local line_info = vim.api.nvim_win_get_cursor(0)
	local line_number = line_info[1]
	local column = line_info[2] + 1
	return { filename, line_number, column }
end

return M
