local _string = {}

function _string.includes(str, substr)
	return string.find(str, substr, 1, true)
end

return _string