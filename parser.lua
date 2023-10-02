local Error = require("error")

local Parser = {}
Parser.__index = Parser

function Parser.new(self, filename, tokens)
	local this = setmetatable({}, self)

	this.filename = filename
	this.tokens = tokens

	return this
end

function Parser.at(self)
	return self.tokens[1]
end

function Parser.next(self)
	return self.tokens[2]
end

function Parser.yum(self)
	local prev = self:at()
	table.remove(self.tokens, 1)
	return prev
end

function Parser.notEof(self)
	return self:at().type ~= "eof"
end

function Parser.makeAst(self)
	local ast = {
		type = "Program",
		body = {},
	}

	while self:notEof() do
		local node = self:parseStmt()

		if not node["type"] then
			return ast, node
		end

		table.insert(ast.body, node)
	end

	return ast
end

function Parser.parseStmt(self)
	local token = self:at()
	local next = self:next()

	if token:match("Ident", "var") or token:match("Ident", "let") then
		return self:parseVarDeclaration()
	end

	return self:parseExpr()
end

function Parser.parseVarDeclaration(self)
	self:yum()
	local ident = self:yum().value

	if not self:at():match("BinOp", "=") then
		return {
			type = "VarDeclaration",
			ident = ident,
			value = {
				type = "NullLiteral",
			},
		}
	end

	self:yum()
	local value = self:parseExpr()

	return {
		type = "VarDeclaration",
		ident = ident,
		value = value,
	}
end

function Parser.parseExpr(self)
	local next = self:next()

	if next.type == "BinOp" then
		if next.value == "=" then
			return self:parseAssignmentExpr()
		end

		return self:parseAdditiveExpr()
	end

	return self:parsePrimaryExpr()
end

function Parser.parseAssignmentExpr(self)
	local ident = self:yum().value
	self:yum()
	local value = self:parseExpr()

	return {
		type = "AssignmentExpr",
		ident = ident,
		value = value,
	}
end

function Parser.parseAdditiveExpr(self)
	local left = self:parseMultiplicativeExpr()

	while self:notEof() and ( self:at().value == "+" or self:at().value == "-" ) do
		local operator = self:yum().value
		local right = self:parseMultiplicativeExpr()

		return {
			type = "BinaryExpr",
			left = left,
			operator = operator,
			right = right,
		}
	end

	return left
end

function Parser.parseMultiplicativeExpr(self)
	local left = self:parsePrimaryExpr()

	while self:notEof() and ( self:at().value == "*" or self:at().value == "/" ) do
		local operator = self:yum().value
		local right = self:parsePrimaryExpr()

		return {
			type = "BinaryExpr",
			left = left,
			operator = operator,
			right = right,
		}
	end

	return left
end

function Parser.parsePrimaryExpr(self)
	local token = self:yum()

	if token.type == "Number" then
		return {
			type = "NumericLiteral",
			value = token.value
		}
	elseif token.type == "String" then
		return {
			type = "StringLiteral",
			value = token.value,
		}
	elseif token.type == "Ident" then
		if token.value == "true" or token.value == "false" then
			local val = false

			if token.value == "true" then
				val = true
			end

			return {
				type = "BooleanLiteral",
				value = val
			}
		end

		return {
			type = "Identifier",
			name = token.value,
		}
	elseif token.type == "BinOp" then
		if token.value == ";" then
			self:yum()
		end
	end

	return Error:new(self.filename, token.pos, "Token type '" .. token.type .. "' has not been initialized for parsing")
end

return Parser