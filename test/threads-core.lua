local mock = require("luassert.mock")

describe("threads", function()
	before_each(function()
		local Thread = require("threads.threads-core")
		TestThread = Thread.new("test-thread")
	end)
	it("can create base thread class", function()
		assert.are.equal(TestThread.name, "test-thread")
		assert.are.equal(TestThread.count, 0)
		assert.is_nil(TestThread.active_mark)
	end)
	it("can add marks to thread instance", function()
		-- Add 3 marks with mocked values
		for i = 1, 3 do
			-- Mock vim.api.nvim_buf_get_name to return a test filename
			vim.api.nvim_buf_get_name = mock(vim.api.nvim_buf_get_name, true)
			vim.api.nvim_buf_get_name.returns("mocked_filename" .. i)

			-- Mock vim.api.nvim_win_get_cursor to return a test cursor position
			vim.api.nvim_win_get_cursor = mock(vim.api.nvim_win_get_cursor, true)
			vim.api.nvim_win_get_cursor.returns({ i + 1, i + 1 })
			TestThread:add_mark()
		end
		--- Verify that the mocked Neovim API was called
		assert.stub(vim.api.nvim_buf_get_name).was_called(3)
		assert.stub(vim.api.nvim_win_get_cursor).was_called(3)

		-- Check that marks were added correctly
		assert.is_not_nil(TestThread.marks)
		assert.are.equal(3, #TestThread.marks)

		-- Check active_mark is last mark that was added
		assert.are.equal(TestThread.active_mark.filename, "mocked_filename3")
		assert.are.equal(TestThread.active_mark.line_number, 4)
		assert.are.equal(TestThread.active_mark.column, 4)

		-- Restore the mocks
		mock.revert(vim.api.nvim_buf_get_name)
		mock.revert(vim.api.nvim_win_get_cursor)
	end)
end)
