local Path = require("plenary.path")

--{"thread_1": [{"filename": "foo.py"}, {"filename": "bazz.py"}]}

local M = {}

M.data_path = string.format("%s/threads", vim.fn.stdpath("data"))

function M.create_data_dir()
	local path = Path:new(M.data_path)
	if not path:exists() then
		path:mkdir()
	end
end

function M.get_data_file_path()
	local curr_working_dir = vim.loop.cwd()
	local full_data_path = string.format("%s/%s.json", M.data_path, vim.fn.sha256(curr_working_dir))
	return full_data_path
end

function M.create_thread_data_file()
	local full_data_path = M.get_data_file_path()
	local path = Path:new(full_data_path)
	if not path:exists() then
		path:touch()
	end
	return full_data_path
end

function M.add_thread(thread_name)
	local full_data_path = M.get_data_file_path()
	local threads = M.get_threads_data(full_data_path)
	if threads[thread_name] == nil then
		threads[thread_name] = {}
	else
		error("Thread with name " .. thread_name .. " already exists")
	end
	local content = vim.json.encode(threads)
	local path = Path:new(full_data_path)
	path:write(content, "w")
end

function M.get_threads_data(filepath)
	local path = Path:new(filepath)
	local file_content = path:read()
	if file_content == "" then
		path:write("{}", "w")
	end
	local data = vim.json.decode(path:read())
	return data
end

function M.write_thread_data(thread)
	local full_data_path = M.get_data_file_path()
	local threads = M.get_threads_data(full_data_path)
	threads[thread.name] = thread.marks
	local content = vim.json.encode(threads)
	local path = Path:new(full_data_path)
	path:write(content, "w")
end

return M
