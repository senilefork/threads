local Path = require("plenary.path")

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

--[[ 
	I need a function that can read the data file and find the json
	object that represents the thread specified. 
	This means that the function needs to take the thread name as an argument.
	It then needs to take that json object and instantiate a thread class loaded 
	with the data from the json object. 
	It then needs to create a thread session with the newly instantiated thread class.
--]]

function M.get_thread(thread_name)
	local full_data_path = M.get_data_file_path()
	local data = M.get_threads_data(full_data_path)
	local thread_data = data[thread_name]
	if thread_data == nil then
		error("No thread with name " .. thread_name)
	end
	-- P(thread_data)
	return thread_data
end
return M
