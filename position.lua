local Position = {}
Position.__index = Position

function Position.new(self, index, line, column)
	local this = setmetatable({}, self)

	this.index = index
	this.line = line
	this.column = column

	return this
end

function Position.advance(self, char, delta)
	self.index = self.index + delta
	self.column = self.column + delta

	if char == "\n" then
		self.column = 0
		self.line = self.line + 1
	end

	return self
end

function Position.clone(self)
	return Position:new(self.index, self.line, self.column)
end

return Position