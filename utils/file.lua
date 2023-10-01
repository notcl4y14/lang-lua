function readfile(filename)
	local file = io.open(filename)

	if not file then
		return
	end

	local content = file:read("*all")
	file:close()

	return content
end