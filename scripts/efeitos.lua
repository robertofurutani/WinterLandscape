--Efeitos de transição
function transFade (item, delay, tempo, funcOnComplete )
	item.alpha=0
	transition.to( item, {delay=delay, time=tempo, alpha=1, transition=easing.inOutQuad, onComplete=funcOnComplete })
end

function criarAnimacao(cardImage, path, reversed)
	reversed = reversed or false
	local frameCount = 35
    local sheetData = { width=270, height=382, numFrames=frameCount, sheetContentWidth=9450, sheetContentHeight=382 }
    
    local mySheet = graphics.newImageSheet( path, sheetData )

	local frameSequenceReversed = {}
	for i = 1, frameCount do
		frameSequenceReversed[i]=i
	end
	table.sort(frameSequenceReversed, function(a, b) return a > b end)
	
    local sequenceData = reversed and {frames = frameSequenceReversed, time=1000, loopCount = 1} or {start=1, count=frameCount, time=1000, loopCount = 1}
    
    animation = display.newSprite( mySheet, sequenceData )

    animation.anchorX = 0.5
    animation.anchorY = 0.5

	cardImage.isVisible=false
    animation.x = cardImage.x
    animation.y = cardImage.y
    animation.rotation = cardImage.rotation

    return animation
end