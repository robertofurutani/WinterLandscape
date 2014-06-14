DecisionBox = {}
DecisionBox.__index = DecisionBox

-- The last four itens are the objects
function DecisionBox.create(arrayRotation,colorNames,colorArray,layer,confirmImage,cancelImage,titleText,descriptionText)
    local object = {}
    setmetatable(object,DecisionBox)
    object.arrayX={300, 300, 300, 300, 300}
	object.arrayY={350, 350, 350, 350, 350}
	object.arrayRotation=arrayRotation
	object.colorNames=colorNames
	object.colorArray=colorArray
	object.layer=layer
	object.layer.alpha=0
	object.confirmImage=confirmImage
	object.confirmImage.x = 0
	object.confirmImage.y = 100
	object.cancelImage=cancelImage
	object.cancelImage.x = 0
	object.cancelImage.y = 180
	object.titleText=titleText
	object.titleText.x = 0
	object.titleText.y = 50
	object.descriptionText=descriptionText
	object.descriptionText.x = 0
	object.descriptionText.y = 70
    return object
end

function DecisionBox:activate(playerTurn,text,blacktext)
	local index = playerTurn
	local colorNumber = blacktext and 1 or 0
	self.layer.x=self.arrayX[index]
	self.layer.y=self.arrayX[index]
	self.layer.rotation = self.arrayRotation[index]
	self.titleText.text="Jogador "..self.colorNames[index]..":"
	self.titleText:setFillColor(self.colorArray[index][1],self.colorArray[index][2],self.colorArray[index][3])
	self.descriptionText.text=text
	self.descriptionText:setFillColor(colorNumber,colorNumber,colorNumber)
	transition.to( self.layer, { time=400, alpha=1, transition=easing.inOutQuad })
end

function DecisionBox:deactivate() 
	transition.to( self.layer, { time=400, alpha=0, transition=easing.inOutQuad })
end