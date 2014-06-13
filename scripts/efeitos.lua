--Efeitos de transição
function transFade (item, delay, tempo )
	 item.alpha=0
	 transition.to( item, {delay=delay, time=tempo, alpha=1, transition=easing.inOutQuad })
end

function transFade (item, delay, tempo, funcOnComplete )
	 item.alpha=0
	 transition.to( item, {delay=delay, time=tempo, alpha=1, transition=easing.inOutQuad, onComplete=funcOnComplete })
end

function criarAnimacao( x, y, rotation, carta )
    local sheetData = { width=270, height=382, numFrames=35, sheetContentWidth=9450, sheetContentHeight=382 }
    local filename = ("carta"..carta.."Rotate.png")
    
    local mySheet = graphics.newImageSheet( filename, sheetData )

	local frameCount = 35
	local frameSequenceReversed = {}
	for i = 1, frameCount do
		frameSequenceReversed[i]=i
	end
	table.sort(frameSequenceReversed, function(a, b) return a > b end)
	
    local sequenceData = {
        { name = "indo", start=1, count=frameCount, time=1000, loopCount = 1 },
        { name = "reverse", frames = frameSequenceReversed, time=1000, loopCount = 1 }
    }
     
    animation = display.newSprite( mySheet, sequenceData )

    animation.anchorX = 0.5
    animation.anchorY = 0.5

    animation.x = x
    animation.y = y
    animation.rotation = rotation
     
    animation.id= "Animacao Carregada"

    return animation
end