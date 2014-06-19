require("scripts.player")
require("scripts.decisionBox")

local IMGDIR = "images/game/"

local DISTANCEGOAL = 20

local CARTA_CACADOR=1
local CARTA_PESCADOR=2
local CARTA_PATINADOR=3
local CARTA_DIABO=4
local CARTA_CORVO=5
local CARTA_LADRAO=6

local PLAYERSROTATION = {45,135,225,270,315}
local PLAYERSTEXTCOLOR = {{0.9, 0.9, 0.5},{0.6, 0.6, 1},{1, 0.4, 0.8},{1, 0.6, 0.6},{0.8, 1, 0.6}}
local CARDANIMATIONNAMES = ({
	[CARTA_CACADOR]="cartaCacadorRotate.png",
	[CARTA_PESCADOR]="cartaPescadorRotate.png",
	[CARTA_PATINADOR]="cartaPatinadorRotate.png",
	[CARTA_DIABO]="cartaDiaboRotate.png",
	[CARTA_CORVO]="cartaCorvoRotate.png",
	[CARTA_LADRAO]="cartaLadraoRotate.png",
})
local COLORNAMES = {"Amarelo","Azul","Rosa","Vermelho", "Verde"}
local FONT = "Garamond Premr Pro"

-- GUI
local playersHUD = {}
local playersHUDBirds = {}
local playersHUDFish = {}
local playersIcons = {}
local cards = {}
local mainHUDBars={}
local mainHUDText=nil
local deadIcon=nil
local blackBlock=nil
local board=nil
local decisionBox=nil

-- Steps
local STEP_SELECTCARD=1
local STEP_KILLER=2
local STEP_ACTION=3
local STEP_MOVE=4
local STEP_NEWORDER=5

-- Others
local playerCount = 0
local players = {}
local firstPlayer=0
local playerTurn=0
local step=0
local selectedCard = 0
local selectedCardLayerIndex = 0
local decisionTime = false
local gameOccurring=false
local touchTimeout=0
local turnNumber=0

--------------------------------------------------
--- Initialize/Finalize functions
--------------------------------------------------

function initializeGame(playersNumber, functionAfterFade)
	playerCount = playersNumber
	
	-- Initialize player objects
	for i = 1, playerCount do
		players[i]=Player.create(i)
	end
	
	gameLayer=display.newGroup()
	board = display.newImageRect( gameLayer,IMGDIR.."tabuleiro.png", 760, 1024)
	
	-- Cards image
	local cardCount=1
	for _,cardIndex in ipairs({CARTA_CACADOR,CARTA_PESCADOR,CARTA_PATINADOR,CARTA_DIABO,CARTA_CORVO,CARTA_LADRAO}) do
		local cardPath = ({
			[CARTA_CACADOR]="cartaCacadorFrente.png",
			[CARTA_PESCADOR]="cartaPescadorFrente.png",
			[CARTA_PATINADOR]="cartaPatinadorFrente.png",
			[CARTA_DIABO]="cartaDiaboFrente.png",
			[CARTA_CORVO]="cartaCorvoFrente.png",
			[CARTA_LADRAO]="cartaLadraoFrente.png",
		})[cardIndex] 
		cards[cardIndex] = display.newImageRect( gameLayer, IMGDIR..cardPath, 142, 190 )
		cards[cardIndex].anchorX = 0.5
		cards[cardIndex].anchorY = 0.5
		cards[cardIndex]:addEventListener( "touch", cardTouch)
		
	    local x, y, rotation = nonPlayerCardXYRotation(cardIndex)
		cards[cardIndex].x=x-150
		cards[cardIndex].y=y
		cards[cardIndex].rotation=rotation
		transition.to(cards[cardIndex], {delay=1000+300*cardCount, time=1200, x=x, y=y, transition=easing.inOutQuad})
		
		cardCount=cardCount+1
	end
	
	-- Dead Icon
	deadIcon = display.newImageRect( gameLayer, IMGDIR.."lapide.png", 58, 85 )
	deadIcon.alpha = 0
	
	for i = 1, playerCount do 
		-- Player HUD
		local playersHUDPath = ({"player1Hud.png","player2Hud.png","player3Hud.png","player4Hud.png","player5Hud.png"})[i]
		playersHUD[i] = display.newImageRect( gameLayer, IMGDIR..playersHUDPath, ({208, 239, 207, 91, 241})[i], ({247, 209, 240, 394, 208})[i])
		local hudFinalX = ({37, 37, 553, 669, 519})[i]
		local hudFinalY = ({777, 0, 0, 315, 816})[i]
		local hudWidth = playersHUD[i].width
		local hudHeight = playersHUD[i].height
		-- Initial position before the HUD appears at screen
		playersHUD[i].x = ({-hudWidth, -hudWidth, hudWidth, hudWidth, hudWidth})[i] + hudFinalX
		playersHUD[i].y = ({hudHeight, -hudHeight, -hudHeight, 0, hudHeight})[i] + hudFinalY
	    transition.to(playersHUD[i], {delay=1000+400*i, time=2000, x=hudFinalX, y=hudFinalY, transition=easing.inOutQuad})
		playersHUD[i]:addEventListener( "touch", playerTouch)
		
		-- Birds counter
		playersHUDBirds[i] = display.newText({parent=gameLayer, text="0",font=FONT, fontSize=22})
		playersHUDBirds[i].x = ({57, 57, 573, 589, 539})[i]
		playersHUDBirds[i].y = ({777, 0, 0, 315, 816})[i]
		playersHUDBirds[i]:setFillColor(PLAYERSTEXTCOLOR[i][1],PLAYERSTEXTCOLOR[i][2],PLAYERSTEXTCOLOR[i][3])
		playersHUDBirds[i].anchorX = 0.5
		playersHUDBirds[i].rotation = PLAYERSROTATION[i]
		playersHUDBirds[i].alpha=0
		transition.to ( playersHUDBirds[i], { delay=5000, time=2000, alpha=1, transition=easing.inOutQuad})
		
		-- Fish counter
		playersHUDFish[i] = display.newText({parent=gameLayer, text="0",font=FONT, fontSize=22})
		playersHUDFish[i].x = ({67, 67, 583, 599, 549})[i]
		playersHUDFish[i].y = ({777, 0, 0, 315, 816})[i]
		playersHUDFish[i]:setFillColor(PLAYERSTEXTCOLOR[i][1],PLAYERSTEXTCOLOR[i][2],PLAYERSTEXTCOLOR[i][3])
		playersHUDFish[i].anchorX = 0.5
		playersHUDFish[i].rotation = PLAYERSROTATION[i]
		playersHUDFish[i].alpha=0
		transition.to ( playersHUDFish[i], { delay=5000, time=2000, alpha=1, transition=easing.inOutQuad})
		
		-- Players Icons
		local playersIconsPath = ({"playerYellow.png","playerBlue.png","playerPink.png","playerRed.png","playerGreen.png"})[i] 
		playersIcons[i] = display.newImageRect( gameLayer, IMGDIR..playersIconsPath, 19, 35 )
		playersIcons[i].x = ({300, 325, 350, 375, 400})[i]
		playersIcons[i].y = playerIconY(i)
		
		-- Draw all bar at the same positions, but only the right one will be visible
		local mainHUDBarsPaths = {"barraYellow.png","barraBlue.png","barraPink.png","barraRed.png","barraGreen.png"}
		mainHUDBars[i] = display.newImageRect( gameLayer, IMGDIR..mainHUDBarsPaths[i], 760, 1024 )
		mainHUDBars.isVisible = false
	end
	
	-- Black block used at decision time
	blackBlock = display.newRect(gameLayer, 0, 0, 768, 1024)
	blackBlock:setFillColor(0,0,0)
	blackBlock.alpha=0
	
	-- Main HUD text
	mainHUDText = display.newText({parent=gameLayer, x=18, y=0, text="",font=FONT, fontSize=32})
	mainHUDText.y = display.viewableContentHeight/2
	mainHUDText.anchorX = 0.5
	mainHUDText.anchorY = 0.5
	mainHUDText.rotation = 90	
	
	-- Decision Box
	local decisionBoxLayer = display.newGroup()
	gameLayer:insert( decisionBoxLayer )
	local confirmButton = display.newImageRect( decisionBoxLayer, IMGDIR.."botaoConfirmar.png", 97, 97 )
	local cancelButton = display.newImageRect( decisionBoxLayer, IMGDIR.."botaoRecusar.png", 97, 97 )
	confirmButton:addEventListener( "touch", confirmTouch)
	cancelButton:addEventListener( "touch", cancelTouch)
	local titleText = display.newText({parent=decisionBoxLayer, text="",font=FONT, fontSize=22})
	local descriptionText = display.newText({parent=decisionBoxLayer, text="",font=FONT, fontSize=16})
	decisionBox = DecisionBox.create(PLAYERSROTATION,COLORNAMES,PLAYERSTEXTCOLOR,decisionBoxLayer,confirmButton,cancelButton,titleText,descriptionText)	
	
	transFade( gameLayer, 0, 3000, functionAfterFade)
	
	gameOccurring=true
	
	AudioUtil.playBGM("sound_inGame.mp3")
	firstPlayer=math.random(playerCount)
	setTouchWaitTime(3500)
	nextTurn()
end

-- Remove all images, restart the layer and going back to the menu screen
function finalizeGame()
	--board=nil
	--mainHUDText=nil
	--confirmButton=nil
	--cancelButton=nil
	--blackBlock=nil
	playersHUDBirds={}
	playersHUDFish={}
	playersHUD={}
	playersIcons={}
	cards={}
	decisionBox:finalize()
	decisionBox=nil
	gameLayer:removeSelf()
	gameLayer=nil
	
	playerCount = 0
	players = {}
	firstPlayer=0
	playerTurn=0
	step=0
	selectedCard = 0
	decisionTime = false
	turnNumber=0
end


function declareVictory(playerIndex)
	finalizeGame()
	AudioUtil.playBGM("sound_success.mp3")
	victoryLayer = display.newGroup()
	local victoryScreen = display.newImageRect( victoryLayer, IMGDIR.."victoryscreen.jpg", 768, 1024 )
	local text = "Vitória do Jogador "..COLORNAMES[playerIndex].."!"
	local victoryText = display.newText({parent=victoryLayer, x=100, y=100, text=text,font=FONT, fontSize=32})
	victoryText.anchorY = 0.5
	victoryText.rotation = 90
	victoryText:setFillColor(0,0,0) 
	
	local restart = function() 
		if victoryLayer then
			victoryLayer:removeSelf()
			victoryLayer=nil
		end
		audio.fadeOut({channel=0})
		mostrarIntro()
	end
	transFade (victoryLayer, 0, 1000,function() victoryLayer:addEventListener( "touch",restart); end)
end

--------------------------------------------------
--- Other functions
--------------------------------------------------

function setTouchWaitTime(milliseconds)
	touchTimeout=system.getTimer()+milliseconds
end

function touchReady() -- Return if touch isn't waiting waitTime
	return touchTimeout<system.getTimer()
end

function nextTurn()
	-- TODO animation for next turn
	step = STEP_SELECTCARD
	turnNumber=turnNumber+1
	-- Remove the card and revives everyone
	for i = 1, playerCount do
		if players[i].card>0 then removePlayerCard(i) end
		if players[i].dead then revivePlayer(i) end
	end
	playerTurn=firstPlayer
	highlightPlayer(playerTurn)
end

-- If a player have the right card, he call kill someone. Else go to the next step. Return if there is a killer among us
function killChoice()
	for i = 1, playerCount do
		if players[i].card==CARTA_DIABO then
			step = STEP_KILLER
			AudioUtil.playBGM("sound_gameOver.mp3")
			playerTurn=i
			highlightPlayer(playerTurn)
			return
		end
	end
	initializeActionTurn()
end

function initializeActionTurn()
	-- Give bird to everyone
	for i = 1, playerCount do
		birdsReceived = (players[i].card==CARTA_CACADOR and not players[i].dead) and 2 or 1 
		setPlayerBirds(i,players[i].birds+birdsReceived)
	end
	--TODO animation
	step = STEP_ACTION
	nextAction(true)
end

function nextAction(firstTurn) -- If firstTurn == true then doesn't calls nextPlayerTurn
	firstTurn = false or firstTurn
	if not gameOccurring then return end 
	if firstTurn or nextPlayerTurn() then
		if (players[playerTurn].card==CARTA_LADRAO or players[playerTurn].card==CARTA_CORVO) and not players[playerTurn].dead then
			-- If the player need a target selection
			highlightPlayer(playerTurn)
		elseif not players[playerTurn].dead and (players[playerTurn].card==CARTA_PATINADOR or players[playerTurn].card==CARTA_PESCADOR) then
			if players[playerTurn].card==CARTA_PESCADOR then	-- Transform bird into fish !
				setPlayerFish(playerTurn,players[playerTurn].fish+players[playerTurn].birds)
				setPlayerBirds(playerTurn,0)
				-- TODO Maybe this will mess with the animation
			elseif players[playerTurn].card==CARTA_PATINADOR then
				movePlayerConsumingResources(playerTurn, true)
			end
			if not gameOccurring then return end 
			highlightPlayer(playerTurn)
			timer.performWithDelay(2000,function() nextAction();end)
		else	
			nextAction()
		end
	else
		step = STEP_MOVE
		-- TODO animation for move step
		highlightPlayer(playerTurn)
		activateDecisionTime()
	end
end

function nextMove()
	if not gameOccurring then return end 
	if nextPlayerTurn() then
		if players[playerTurn].dead or players[playerTurn].card==CARTA_LADRAO or players[playerTurn].card==CARTA_PATINADOR or players[playerTurn]:getPoints()==0 then
			nextMove()
		else
			deactivateDecisionTime()
			highlightPlayer(playerTurn)
			timer.performWithDelay(1600,activateDecisionTime)
		end
	else
		deactivateDecisionTime()
		local playerThatDefinesNewOrderIndex = 0
		for i = 1, playerCount do
			if players[i].card==CARTA_DIABO then
				playerThatDefinesNewOrderIndex=i
				break
			end
		end
		if playerThatDefinesNewOrderIndex==0 then
			nextTurn()
		else
			step = STEP_NEWORDER
			playerTurn=playerThatDefinesNewOrderIndex
			highlightPlayer(playerTurn)
		end
	end
end

function activateDecisionTime()
	if not gameOccurring then return end 
	decisionTime=true
	local delay = 0 
	decisionBox:activate(playerTurn,(selectedCard==0) and "Andar?" or "Confirma a seleção da carta?")
	if(selectedCard~=0) then -- Do the card animation
		delay = 600 
		gameLayer:remove(cards[selectedCard])
		decisionBox:addCard(cards[selectedCard],IMGDIR..CARDANIMATIONNAMES[selectedCard])
	end
	transition.to(blackBlock, {delay=delay, time=400, alpha=0.9, transition=easing.inOutQuad })
end

function deactivateDecisionTime(playerIndex)
	if not gameOccurring then return end 
	decisionTime=false
	playerIndex = playerIndex or 0 -- 0 acts as no player index
	if(selectedCard~=0) then -- Do the card animation
		delay=1000
		local x,y,rotation = 0,0,0
		if playerIndex==0 then
			x,y,rotation=nonPlayerCardXYRotation(selectedCard)
		else
			x,y,rotation=playerCardXYRotation(playerIndex)
		end
		decisionBox:removeCard(x,y,rotation,IMGDIR..CARDANIMATIONNAMES[selectedCard])
		gameLayer:insert(selectedCardLayerIndex,cards[selectedCard])
	end
	transition.to(blackBlock, {time=400, alpha=0, transition=easing.inOutQuad })
	decisionBox:deactivate()
	selectedCard=0
	selectedCardLayerIndex=0
end

function movePlayerConsumingResources(playerIndex,double)
	double=double or false
	distance=players[playerIndex]:moveConsumingResources(double)
	setPlayerBirds(playerIndex,0) -- Only for updating the counters
	setPlayerFish(playerIndex,0) -- Only for updating the counters
	movePlayerEffects(playerIndex,distance)
end

-- Only checks victory conditions and plays the animation
function movePlayerEffects(playerIndex,distance)
	transition.to(playersIcons[playerIndex], {y=playerIconY(playerIndex), time=800, transition=easing.inOutQuad, onComplete=animacaoCompleta})
	if(players[playerIndex].boardPosition>=DISTANCEGOAL) then 
		gameOccurring=false
		timer.performWithDelay(4000,function() declareVictory(playerIndex) end)
	end
end	

-- Set variable playerTurn to the next player. Returns false if the next player and the first player are equal (the cicle is complete).
function nextPlayerTurn()
	playerTurn = playerTurn==playerCount and 1 or playerTurn+1
	return ( firstPlayer ~= playerTurn )
end

--------------------------------------------------
--- Main text HUD
--------------------------------------------------

function refreshMainHUDText()
	local text="Jogador "..COLORNAMES[playerTurn]..": "
	
	local textAction = {
		[CARTA_CACADOR]="",
		[CARTA_PESCADOR]="Usou seus pássaros para pegar peixes.",
		[CARTA_PATINADOR]="Usou seus recursos para andar o dobro.",
		[CARTA_DIABO]="",
		[CARTA_CORVO]="Escolha de quem irá roubar 2 pássaros ou 1 peixe.",
		[CARTA_LADRAO]="Escolha de quem irá roubar metade dos recursos"
	}
	local textStep={
		[STEP_SELECTCARD]="Selecione sua carta.",
		[STEP_KILLER]="Selecione quem será morto.",
		[STEP_ACTION]=textAction[players[playerTurn].card],
		[STEP_MOVE]="Andar?",
		[STEP_NEWORDER]="Escolha o primeiro jogador do próximo turno."
	}
	local text=text..textStep[step]
	mainHUDText.text=text
	-- Displays the right bar
	for i = 1, playerCount do
		mainHUDBars[i].isVisible = playerTurn==i
	end
end

--------------------------------------------------
--- Functions that change visual/player things
--------------------------------------------------

-- Highlight the player. When param<1 or there is no param = No Highlight 
-- Also, refreshes the mainHUDText
function highlightPlayer(playerIndex)
	-- Only refreshes the mainHUDText now.
	refreshMainHUDText()
end

function removePlayerCard(playerIndex)
	local oldCard = players[playerIndex].card
	players[playerIndex].card=0
	--TODO animation
	if oldCard>0 then
		local x, y, rotation = nonPlayerCardXYRotation(oldCard) 
		transition.to(cards[oldCard], {delay=0, time=400, x=x, y=y, rotation=rotation, transition=easing.inOutQuad })
		setTouchWaitTime(500)
	end
end

function playerCardXYRotation(playerIndex)
	local x = ({57, 57, 573, 589, 539})[playerIndex]
	local y = ({777, 0, 0, 315, 816})[playerIndex]
	return x,y,PLAYERSROTATION[playerIndex]
end

function nonPlayerCardXYRotation(cardIndex)
	local x = 50
	local y = 160 + 96 * cardIndex
	local rotation = 70
	return x,y,rotation
end

function setPlayerBirds(playerIndex, birds)
	players[playerIndex].birds = birds
	playersHUDBirds[playerIndex].text=players[playerIndex].birds
	--TODO animation
end

function setPlayerFish(playerIndex, fish)
	players[playerIndex].fish = fish
	playersHUDFish[playerIndex].text=players[playerIndex].fish
	--TODO animation
end

function killPlayer(playerIndex)
	players[playerIndex].dead=true
	AudioUtil.playSE("Die")
	timer.performWithDelay(1200,function() AudioUtil.playBGM("sound_inGame.mp3") end)
	setTouchWaitTime(3500)
	-- Change the only icon position, since only only one player can be dead per turn
	deadIcon.x = ({57, 57, 573, 589, 539})[playerIndex]
	deadIcon.y = ({777, 0, 0, 315, 816})[playerIndex]
	deadIcon.rotation=PLAYERSROTATION[playerIndex]
	transition.to(deadIcon, { time=400, alpha=1, transition=easing.inOutQuad})
	--TODO animation
end

function revivePlayer(playerIndex)
	players[playerIndex].dead=false
	transition.to(deadIcon, { time=400, alpha=0, transition=easing.inOutQuad})
	--TODO animation
end

-- Return the player Y based in the boardPosition
function playerIconY(playerIndex)
	-- Defines the first and last positions
	local firstY=720
	local lastY=320
	local boardPosition = players[playerIndex].boardPosition
	if boardPosition>DISTANCEGOAL then boardPosition=DISTANCEGOAL end -- precaution
	return firstY-(firstY-lastY)*(boardPosition-1)/(DISTANCEGOAL-1)
end

--------------------------------------------------
--- Touch listeners
--------------------------------------------------

function cardTouch (event)
	local cardIndex = 0
	if (event.phase == "ended") then
		if not touchReady() then return true end
		for i = 1, #cards do
			if (event.target == cards[i]) then
				cardIndex=i
				break
			end
		end
	end
	if cardIndex ~=0 and not decisionTime then
		-- Selected card options at each step
		if step == STEP_SELECTCARD then
			-- Ignores if the card was already selected
			local alreadySelected = false
			for playerIndex = 1, playerCount do
				if players[playerIndex].card==cardIndex then alreadySelected=true end
			end
			if not alreadySelected then
				selectedCard=cardIndex
				for i =1, gameLayer.numChildren do -- Get the index and store at selectedCardLayerIndex
					if cards[selectedCard] == gameLayer[i] then
						selectedCardLayerIndex = i
						break
					end
				end
				setTouchWaitTime(2000)
				activateDecisionTime()
			end
			return true
		end
	end
end

function playerTouch (event)
	local playerIndex = 0
	if (event.phase == "ended") then
		if not touchReady() then return true end
		for i = 1, playerCount do
			if (event.target == playersHUD[i]) then
				playerIndex = i
				break
			end
		end
	end
	if playerIndex ~= 0 and not decisionTime then
		-- Selected player option at each step
		if step == STEP_KILLER then
			if playerIndex~=playerTurn then  -- Suicide isn't allowed
				killPlayer(playerIndex)
				-- Next step
				firstPlayer=playerTurn
				initializeActionTurn()
			end
			return true
		elseif step == STEP_ACTION then
			if playerIndex~=playerTurn then -- Clicked at the target
				if players[playerTurn].card==CARTA_LADRAO then
					local stolen = players[playerIndex]:getHalfBirdsAndFish()
					local stolenBirds=stolen[1]
					local stolenFish=stolen[2]
					setPlayerFish(playerIndex,players[playerIndex].fish-stolenFish)
					setPlayerBirds(playerIndex,players[playerIndex].birds-stolenBirds)
					setPlayerFish(playerTurn,players[playerTurn].fish+stolenFish)
					setPlayerBirds(playerTurn,players[playerTurn].birds+stolenBirds)
					-- TODO Maybe this will mess with the animation
					-- TODO Animation
					nextAction()
				elseif players[playerTurn].card==CARTA_CORVO then
					local stolenPoints = 0
					if players[playerIndex].fish>0 then
						stolenPoints=2
						setPlayerFish(playerIndex,players[playerIndex].fish-2)
					else
						-- If is less than 2, steal all.
						stolenPoints = players[playerIndex].birds<2 and players[playerIndex].birds or 2
						setPlayerBirds(playerIndex,players[playerIndex].birds-stolenPoints)
					end
					players[playerTurn].boardPosition = players[playerTurn].boardPosition+stolenPoints
					movePlayerEffects(playerTurn,stolenPoints)
					nextAction()
				end
			end
			return true
		elseif step == STEP_NEWORDER then
			if playerIndex~=playerTurn then  -- Cannot choose yourself for the first in the next turn
				firstPlayer=playerIndex
				nextTurn()
			end
			return true
		end
	end
end

function confirmTouch (event)
	if (event.phase == "ended") and decisionTime then
		if not touchReady() then return true end
		if step == STEP_SELECTCARD then
			players[playerTurn].card=selectedCard
			setTouchWaitTime(1000)
			deactivateDecisionTime(playerTurn)
			if nextPlayerTurn() then
				highlightPlayer(playerTurn)
			else
				killChoice()
			end
		elseif step == STEP_MOVE then
			movePlayerConsumingResources(playerTurn)
			nextMove()
		end		
		return true
	end
end

function cancelTouch (event)
	if (event.phase == "ended") and decisionTime then
		if not touchReady() then return true end
		if step == STEP_SELECTCARD then
			setTouchWaitTime(1000)
			deactivateDecisionTime()
		elseif step == STEP_MOVE then
			nextMove()
		end		
		return true
	end
end