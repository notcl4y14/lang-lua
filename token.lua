local Token = {}
Token.__index = Token

function Token.new(self, type, value, pos)
	local this = setmetatable({}, self)

	this.type = type
	this.value = value or nil
	this.pos = pos

	return this
end

function Token.match(self, type, value)
	return self.type == type and self.value == value
end

function Token.asString(self)
	return "[" .. self.type .. ": " .. tostring(self.value) .. "]"
end

return Token