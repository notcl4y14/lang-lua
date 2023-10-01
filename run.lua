local Lexer = require("lexer")

local function run(filename, code)
	local lexer = Lexer:new(filename, code)
	local tokens, errors = lexer:tokenize()

	if #errors > 0 then
		for _, err in pairs(errors) do
			print(err:asString())
		end

		return
	end

	for _, token in pairs(tokens) do
		print(token:asString())
	end
end

return run