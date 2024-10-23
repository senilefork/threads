local mock = require("luassert.mock")
local Path = require("plenary.path")

local Thread = require("threads.threads-core")

local thread = Thread.new("test-thread")
local test_dir = Path:new("/tmp/test")
test_dir:mkdir()

local are_eq = function(table1, table2)
	for key, _ in pairs(table1) do
		if table1[key] ~= table2[key] then
			return false
		end
	end
	return true
end

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

for i = 1, 4 do
	mock_get_window_info("mocked_filename" .. i, { i, i })
	thread:add_mark()
end

describe("data", function()
	it("can create data file path strings correctly", function()
		local data = require("threads.data")
		data.data_path = test_dir
		vim.loop.cwd = mock(vim.loop.cwd, true)
		local work_dir = "test/workdir"
		vim.loop.cwd.returns(work_dir)
		assert.are.equal(data.get_data_file_path(), string.format("%s/%s.json", test_dir, vim.fn.sha256(work_dir)))
	end)
	it("can add data files to data directory", function()
		local data = require("threads.data")
		data.data_path = test_dir
		vim.loop.cwd = mock(vim.loop.cwd, true)
		local work_dir = "test/workdir"

		vim.loop.cwd.returns(work_dir)
		data.create_thread_data_file()
		local file = Path:new(string.format("%s/%s.json", test_dir, vim.fn.sha256(work_dir)))
		assert.is.True(file:exists())
		file:rm(string.format("%s/%s.json", test_dir, vim.fn.sha256(work_dir)))
	end)
	it("can write thread data to file", function()
		local data = require("threads.data")
		data.data_path = test_dir
		vim.loop.cwd = mock(vim.loop.cwd, true)
		local work_dir = "test/workdir"

		vim.loop.cwd.returns(work_dir)
		data.create_thread_data_file()
		data.add_thread(thread.name)
		data.write_thread_data(thread)
		local file = Path:new(string.format("%s/%s.json", test_dir, vim.fn.sha256(work_dir)))
		local threads_data = data.get_threads_data(file)
		local marks = threads_data[thread.name]

		for i in ipairs(thread.marks) do
			assert.is.True(are_eq(thread.marks[i], marks[i]))
		end

		file:rm()
	end)
end)
test_dir:rmdir()
