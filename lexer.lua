local Token = require("token")
local Position = require("position")
local Error = require("error")

local str_includes = require("utils/string").includes

local lexer = {}
lexer.__index = lexer

local strings = {
	WHITESPACE = " \t\r\n",
	OPERATORS = "+-*/%=.,:;!<>&|",
	PARENTHESES = "()",
	BRACKETS = "[]{}",
	DIGITS = "1234567890",
	QUOTES = "\"'`",
	IDENT = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_",
}

function lexer.new(self, filename, code)
	local this = setmetatable({}, self)

	this.filename = filename
	this.code = code
	this.pos = Position:new(0, 1, 0)

	this:advance()

	return this
end

function lexer.at(self)
	return string.sub(self.code, self.pos.index, self.pos.index)
end

function lexer.advance(self, delta)
	local delta = delta or 1
	-- self.pos = self.pos + delta
	self.pos:advance(self:at(), delta)
end

function lexer.notEof(self)
	return self.pos.index <= string.len(self.code)
end

function lexer.tokenize(self)
	local tokens = {}
	local errors = {}

	while self:notEof() do
		if str_includes(strings.WHITESPACE, self:at()) then
		elseif str_includes(strings.OPERATORS, self:at()) then
			table.insert(tokens, Token:new("BinOp", self:at(), self.pos))

		elseif str_includes(strings.PARENTHESES, self:at()) then
			table.insert(tokens, Token:new("Paren", self:at(), self.pos))

		elseif str_includes(strings.BRACKETS, self:at()) then
			table.insert(tokens, Token:new("Bracket", self:at(), self.pos))

		elseif str_includes(strings.DIGITS, self:at()) then
			table.insert(tokens, self:makeNumber())

		elseif str_includes(strings.QUOTES, self:at()) then
			table.insert(tokens, self:makeString())

		elseif str_includes(strings.IDENT, self:at()) then
			table.insert(tokens, self:makeIdent())

		else
			local char = self:at()
			local pos = self.pos:clone()
			table.insert(errors, Error:new(self.filename, pos, "Undefined character '" .. char .. "'"))
		end

		self:advance()
	end

	table.insert(tokens, Token:new("eof"))

	return tokens, errors
end

function lexer.makeNumber(self)
	local numStr = ""
	local float = false

	while self:notEof() and ( str_includes(strings.DIGITS, self:at()) or self:at() == "." ) do
		if numStr == "." then
			if float then break end
			numStr = numStr .. "."
			float = true
		else
			numStr = numStr .. self:at()
		end

		self:advance()
	end

	self:advance(-1)

	return Token:new("Number", tonumber(numStr), self.pos)
end

function lexer.makeString(self)
	local str = ""
	local quote = self:at()

	self:advance()

	while self:notEof() and self:at() ~= quote do
		str = str .. self:at()
		self:advance()
	end

	return Token:new("String", str, self.pos)
end

function lexer.makeIdent(self)
	local ident = ""

	while self:notEof() and ( str_includes(strings.IDENT, self:at()) or str_includes(strings.DIGITS, self:at()) ) do
		ident = ident .. self:at()
		self:advance()
	end

	self:advance(-1)

	return Token:new("Ident", ident, self.pos)
end

return lexer