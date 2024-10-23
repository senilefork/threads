local mock = require("luassert.mock")

local mock_get_window_info = function(filename, cursor_info)
	vim.api.nvim_buf_get_name = mock(vim.api.nvim_buf_get_name, true)
	vim.api.nvim_buf_get_name.returns(filename)

	-- Mock vim.api.nvim_win_get_cursor to return a test cursor position
	vim.api.nvim_win_get_cursor = mock(vim.api.nvim_win_get_cursor, true)
	vim.api.nvim_win_get_cursor.returns({ cursor_info[1], cursor_info[2] })
	-- Revert modules back
	mock.revert(vim.api.nvim_buf_get_name)
	mock.revert(vim.api.nvim_win_get_cursor)
end
describe("move", function()
	before_each(function()
		local Thread = require("threads.threads-core")
		TestThread = Thread.new("test-thread")
		-- Add 3 marks with mocked values
		for i = 1, 3 do
			mock_get_window_info("mocked_filename" .. i, { i, i })
			TestThread:add_mark()
		end
	end)
	it("can move back one mark while on active_mark", function()
		local move = require("threads.move")
		vim.api.nvim_win_set_cursor = mock(vim.api.nvim_win_set_cursor, true)
		move.move_backward(TestThread)
		local active_mark = TestThread.active_mark
		assert.are.equal(active_mark.filename, "mocked_filename2")
		assert.are.equal(active_mark.line_number, 2)
		assert.are.equal(active_mark.column, 2)
	end)
	it("can move back through length of marks array", function()
		local move = require("threads.move")
		local original_active_mark = TestThread.active_mark
		vim.api.nvim_win_set_cursor = mock(vim.api.nvim_win_set_cursor, true)

		move.move_backward(TestThread)
		mock_get_window_info(
			TestThread.active_mark.filename,
			{ TestThread.active_mark.line_number, TestThread.active_mark.column }
		)
		move.move_backward(TestThread)
		mock_get_window_info(
			TestThread.active_mark.filename,
			{ TestThread.active_mark.line_number, TestThread.active_mark.column }
		)
		move.move_backward(TestThread)
		mock_get_window_info(
			TestThread.active_mark.filename,
			{ TestThread.active_mark.line_number, TestThread.active_mark.column }
		)
		assert.are.equal(original_active_mark.filename, TestThread.active_mark.filename)
		assert.are.equal(original_active_mark.line_number, TestThread.active_mark.line_number)
		assert.are.equal(original_active_mark.column, TestThread.active_mark.column)
	end)
	-- TODO: Figure out how to actually test cursor position
	it("can move to last mark with cursor elsewhere on page", function()
		local move = require("threads.move")
		local active_mark = TestThread.active_mark
		vim.api.nvim_win_set_cursor = mock(vim.api.nvim_win_set_cursor, true)
		mock_get_window_info(active_mark.filename, { 4, 15 })
		move.move_backward(TestThread)
		assert.are.equal(active_mark.filename, "mocked_filename3")
		assert.are.equal(active_mark.line_number, 3)
		assert.are.equal(active_mark.column, 3)
	end)
	it("can move forward to first mark while most recent active mark", function()
		local move = require("threads.move")
		vim.api.nvim_win_set_cursor = mock(vim.api.nvim_win_set_cursor, true)
		move.move_forward(TestThread)
		local active_mark = TestThread.active_mark
		assert.are.equal(active_mark.filename, "mocked_filename1")
		assert.are.equal(active_mark.line_number, 1)
		assert.are.equal(active_mark.column, 1)
	end)
end)
