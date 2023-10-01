require("utils/file")
local run = require("run")

local filename = arg[1]

if not filename then
	print("Please, specify a filename")
	return
end

local code = readfile(filename)

if not code then
	print(filename .. " doesn't exist")
	return
end

run(filename, code)