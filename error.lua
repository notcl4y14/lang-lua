local Error = {}
Error.__index = Error

function Error.new(self, filename, pos, details)
	local this = setmetatable({}, self)

	this.filename = filename
	this.pos = pos
	this.details = details

	return this
end

function Error.asString(self)
	return self.filename .. ":" .. self.pos.line .. ":" .. self.pos.column .. ": " .. self.details
end

return Error