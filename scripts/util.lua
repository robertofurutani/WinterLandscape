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

-- Cut all elements from tableParam that have a bigger difference than maximumDifference (exclusive). 
-- If minimumSum isn't nil, then reduces from every value the minimum value and, after that, sum with minimumSum variable value.
-- Returns a new table
function Util.cutLowValues(tableParam,maximumDifference,minimumSum)
	local retTable={}
	local biggestValue = nil
	for key,value in pairs(tableParam) do -- Picks the bigger value
		if not biggestValue or biggestValue<value then
			biggestValue = value
		end	
	end
	local minimum = biggestValue-maximumDifference
	for key,value in pairs(tableParam) do -- Remove the keys/values that doesn't meet the conditions
		if minimum<=value then
			if minimumSum then
				retTable[key]=value-minimum+minimumSum
			else
				retTable[key]=value
			end	
		end
	end
	return retTable
end

-- Uses all values from a table as percent and select a random key
function Util.selectKeyFromValuePercent(tableParam)
	local total=0
	for key,value in pairs(tableParam) do
		total=total+value
	end
	print("total="..total)
	local selectedNumber=math.random(total)
	local currentValue=0
	for key,value in pairs(tableParam) do
		if selectedNumber<=currentValue+value then return key end
		currentValue=currentValue+value
	end
	return nil
end

return Util