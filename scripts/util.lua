--Util module
local Util = {}

-- Add a Display Object to a layer keeping the position at screen.
function Util.addDisplayObjectKeepingPosition(displayObject,layer)
	local oldX, oldY = displayObject.x, displayObject.y
	displayObject.rotation = displayObject.rotation+360-layer.rotation -- adjust rotation
	layer:insert(displayObject)
	displayObject.x, displayObject.y = layer:contentToLocal(oldX, oldY)
end

-- Remove a Display Object to a layer keeping the position at screen.
function Util.removeDisplayObjectKeepingPosition(displayObject,layer)
	local x,y = displayObject:localToContent(0, 0)
	layer:remove(displayObject)
	displayObject.x, displayObject.y = x,y
	displayObject.rotation = displayObject.rotation+360+layer.rotation -- adjust rotation
end

return Util