local Lexer = require("lexer")
local Parser = require("parser")

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

	local parser = Parser:new(filename, tokens)
	local ast, err = parser:makeAst()

	if err then
		print(err:asString())
		return
	end

	for _, node in pairs(ast.body) do
		print(node.type, node.left, node.operator, node.right, node.value, node.name, node.ident)
	end
end

return run