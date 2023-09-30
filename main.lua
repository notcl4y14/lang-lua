local Lexer = require("lexer")

local lexer = Lexer:new("<stdin>", "+-*/%")
local tokens = lexer:tokenize()

for _, token in pairs(tokens) do
	print(token:asString())
end