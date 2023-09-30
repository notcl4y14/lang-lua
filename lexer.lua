local Token = require("token")

local lexer = {}
lexer.__index = lexer

function lexer.new(self, filename, code)
	local this = setmetatable({}, self)

	this.filename = filename
	this.code = code
	this.pos = 0

	this:advance()

	return this
end

function lexer.at(self)
	return string.sub(self.code, self.pos, self.pos)
end

function lexer.advance(self, delta)
	local delta = delta or 1
	self.pos = self.pos + delta
end

function lexer.notEof(self)
	return self.pos <= string.len(self.code)
end

function lexer.tokenize(self)
	local tokens = {}

	while self:notEof() do
		if self:at() == "+" or self:at() == "-" or self:at() == "*" or self:at() == "/" or self:at() == "%" then
			table.insert(tokens, Token:new("BinOp", self:at()))
		end

		self:advance()
	end

	return tokens
end

return lexer