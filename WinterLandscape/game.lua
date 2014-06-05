require("player")

local DISTANCEGOAL = 20

local CARTA_CACADOR=1
local CARTA_PESCADOR=2
local CARTA_PATINADOR=3
local CARTA_DIABO=4
local CARTA_CORVO=5
local CARTA_LADRAO=6

-- GUI
playersHUD = {}
playersHUDBirds = {}
playersHUDFish = {}
playersIcons = {}
cards = {}
mainHUDBars={}
mainHUDText=nil
passButton=nil
deadIcon=nil
board=nil

-- Steps
STEP_SELECTCARD=1
STEP_KILLER=2
STEP_ACTION=3
STEP_MOVE=4
STEP_NEWORDER=5

-- Others
playerCount = 0
players = {}
firstPlayer=0
playerTurn=0
step=0
gameOccurring=false
turnNumber=0

--------------------------------------------------
--- Initialize/Finalize functions
--------------------------------------------------

function initializeGame(functionAfterFade)
	playerCount = 5
	
	-- Initialize player objects
	for i = 1, playerCount do
		players[i]=Player.create(i)
	end
	
	playersHUDLayer=display.newGroup()
	board = display.newImageRect(bgTabuleiro,"placeholder.jpg", 1024, 768)
	-- board = display.newImageRect( bgboard,"board_fundo.jpg", 1024, 768)
	
	-- Technically this button is only for the moveStep
	passButton = display.newImageRect( playersHUDLayer, "botao5p.png", 53, 55 )
	passButton.x = 825
	passButton.y = 20
	passButton:addEventListener( "touch", passTouch)
	
	-- Main HUD
	mainHUDText = display.newText({parent=playersHUDLayer, x=100, y=730, text="",font=native.systemFont, fontSize=32})
	mainHUDText:setFillColor(0,0,0) 
	local mainHUDBarsPaths = {"barraYellow.png","barraBlue.png","barraPink.png","barraRed.png","barraGreen.png"}
	for i = 1, playerCount do -- Draw all bar at the same positions, but only the right one will be visible
		mainHUDBars[i] = display.newImageRect( playersHUDLayer, mainHUDBarsPaths[i], 760, 1024 )
		mainHUDBars[i].x = 10
		mainHUDBars[i].y = 0
		mainHUDBars.isVisible = false
	end
	
	for i = 1, playerCount do
		-- Birds counter
		playersHUDBirds[i] = display.newText({parent=playersHUDLayer, text="0",font=native.systemFont, fontSize=16})
		playersHUDBirds[i]:setFillColor(0,0,0) 
		playersHUDBirds[i].x = ({125, 225, 325, 425, 525})[i]
		playersHUDBirds[i].y = ({300, 300, 300, 300, 300})[i]
		
		-- Fish counter
		playersHUDFish[i] = display.newText({parent=playersHUDLayer, text="0",font=native.systemFont, fontSize=16})
		playersHUDFish[i]:setFillColor(0,0,0)
		playersHUDFish[i].x = ({150, 250, 350, 450, 550})[i]
		playersHUDFish[i].y = ({300, 300, 300, 300, 300})[i]
		
		-- Player HUD
		local playersHUDPath = ({"botao1p.png","botao2p.png","botao3p.png","botao4p.png","botao5p.png"})[i]
		playersHUD[i] = display.newImageRect( playersHUDLayer, playersHUDPath, 53, 55 )
		playersHUD[i].x = ({125, 225, 325, 425, 525})[i]
		playersHUD[i].y = ({200, 200, 200, 200, 200})[i]
		playersHUD[i]:addEventListener( "touch", playerTouch)
		
		-- Players Icons
		local playersIconsPath = ({"playerYellow.png","playerBlue.png","playerPink.png","playerRed.png","playerGreen.png"})[i] 
		playersIcons[i] = display.newImageRect( playersHUDLayer, playersIconsPath, 19, 35 )
		playersIcons[i].x = ({125, 225, 325, 425, 525})[i]
		positionPlayerIcon(i) -- define icon y
	end
	
	-- Cards image
	for _,cardIndex in ipairs({CARTA_CACADOR,CARTA_PESCADOR,CARTA_PATINADOR,CARTA_DIABO,CARTA_CORVO,CARTA_LADRAO}) do
		local cardPath = ({
			[CARTA_CACADOR]="cartaCacadorFrente.png",
			[CARTA_PESCADOR]="cartaPescadorFrente.png",
			[CARTA_PATINADOR]="cartaPatinadorFrente.png",
			[CARTA_DIABO]="cartaDiaboFrente.png",
			[CARTA_CORVO]="cartaCorvoFrente.png",
			[CARTA_LADRAO]="cartaLadraoFrente.png",
		})[cardIndex] 
		cards[cardIndex] = display.newImageRect( playersHUDLayer, cardPath, 142, 190 )
		cards[cardIndex]:addEventListener( "touch", cardTouch)
		positionNonPlayerCard(cardIndex)
	end
	
	-- Dead Icon
	deadIcon = display.newImageRect( playersHUDLayer, "botaoRecusar.png", 193, 193 )
	deadIcon.isVisible = false
	
	transFade( playersHUDLayer, 0, 3000, functionAfterFade)
	
	gameOccurring=true
	firstPlayer=math.random(5)
	nextTurn()
end

-- Remove all images, restart the layer and going back to the menu screen
function finalizeGame()
	print("finalizeGame")
	board=nil
	passButton=nil
	mainHUDText=nil
	playersHUDBirds={}
	playersHUDFish={}
	playersHUD={}
	playersIcons={}
	cards={}
	playersHUDLayer:removeSelf()
	playersHUDLayer=nil
	
	playerCount = 0
	players = {}
	firstPlayer=0
	playerTurn=0
	step=0
	turnNumber=0
	gameOccurring=false
end


function declareVictory(playerIndex)
	finalizeGame()
	victoryLayer = display.newGroup()
	local victoryScreen = display.newImageRect( victoryLayer, "victoryscreen.jpg", 1024, 768 )
	local text = "Vitória do jogador "..playerIndex.."!"
	local victoryText = display.newText({parent=victoryLayer, x=100, y=730, text=text,font=native.systemFont, fontSize=32})
	victoryText:setFillColor(0,0,0) 
	
	local restart = function() 
		if victoryLayer then
			victoryLayer:removeSelf()
			victoryLayer=nil
		end
		mostrarMenu()
	end
	transFade (victoryLayer, 0, 1000,function() victoryLayer:addEventListener( "touch",restart); end)
end

--------------------------------------------------
--- Other functions
--------------------------------------------------

function nextTurn()
	-- TODO animation for next turn
	step = STEP_SELECTCARD
	turnNumber=turnNumber+1
	print("turnNumber="..turnNumber)
	-- Remove the card and revives everyone
	for i = 1, playerCount do
		removePlayerCard(i)
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
			playerTurn=i
			highlightPlayer(playerTurn)
			-- TODO show a message like "Kill someone"
			print("Kill someone")
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
	print("Resource gain step (birds)")
	--TODO animation
	step = STEP_ACTION
	print("actionStep STARTED")
	nextAction(true)
end

function nextAction(firstTurn) -- If firstTurn == true then doesn't calls nextPlayerTurn
	firstTurn = false or firstTurn
	print("nextAction"..(firstTurn and "true" or "false"))
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
		print("moveStep STARTED")
		-- TODO animation for move step
		highlightPlayer(playerTurn)
	end
end

function nextMove()
	print("nextMove")
	if not gameOccurring then return end 
	if nextPlayerTurn() then
		if players[playerTurn].dead or players[playerTurn].card==CARTA_LADRAO or players[playerTurn].card==CARTA_PATINADOR then
			nextMove()
		else
			highlightPlayer(playerTurn)
		end
	else
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
			print("Choose the next first player")
		end
	end
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
	if (animation==nil) then animation = true end -- Sets default true
	if animation then
		--TODO animation
	end
	positionPlayerIcon(playerIndex)
	players[playerIndex]:printStatus() -- Debug purposes
	if(players[playerIndex].boardPosition>=DISTANCEGOAL) then declareVictory(playerIndex) end
end	

-- Set variable playerTurn to the next player. Returns false if the next player and the first player are equal (the cicle is complete).
function nextPlayerTurn()
	print("extPlayerTurn()")
	playerTurn = playerTurn==playerCount and 1 or playerTurn+1
	return ( firstPlayer ~= playerTurn )
end

--------------------------------------------------
--- Main text HUD
--------------------------------------------------

function refreshMainHUDText()
	local text="Jogador "..playerTurn..": "
	
	textAction = {
		[CARTA_CACADOR]="",
		[CARTA_PESCADOR]="Usou seus pássaros para pegar peixes.",
		[CARTA_PATINADOR]="Usou seus recursos para andar o dobro.",
		[CARTA_DIABO]="",
		[CARTA_CORVO]="Escolha de quem irá roubar 2 pássaros ou 1 peixe.",
		[CARTA_LADRAO]="Escolha de quem irá roubar metade dos recursos"
	}
	
	textStep={
		[STEP_SELECTCARD]="Selecione sua carta.",
		[STEP_KILLER]="Selecione quem será morto.",
		[STEP_ACTION]=textAction[players[playerTurn].card],
		[STEP_MOVE]="Andar?",
		[STEP_NEWORDER]="Escolha o primeiro jogador do próximo turno."
	}
	text=text..textStep[step]
	mainHUDText.text=text
	-- Displays the right bar
	for i = 1, playerCount do
		mainHUDBars[i].isVisible = playerTurn==i
	end
end

--------------------------------------------------
--- Functions that change visual/player things
--------------------------------------------------

-- Implement these methods at player object ?

-- Highlight the player. When param<1 or there is no param = No Highlight 
-- Highlight in red. Also, refreshes the mainHUDText
function highlightPlayer(playerIndex)
	local selectedIndex = playerIndex or 0
	for i = 1, playerCount do
		if i==selectedIndex then playersHUD[i]:setFillColor(1, 0, 0, 1) else playersHUD[i]:setFillColor(1, 1, 1, 1) end
	end
	refreshMainHUDText()
end

function setPlayerCard(playerIndex,card)
	players[playerIndex].card=card
	--TODO animation
	positionPlayerCard(playerIndex,card)
end

function removePlayerCard(playerIndex)
	local oldCard = players[playerIndex].card
	players[playerIndex].card=0
	--TODO animation
	if oldCard>0 then positionNonPlayerCard(oldCard) end
end

function positionPlayerCard(playerIndex,cardIndex)
	cards[cardIndex].x = 25 + 100 * playerIndex
	cards[cardIndex].y = 0
end

function positionNonPlayerCard(cardIndex)
	cards[cardIndex].x = 650
	cards[cardIndex].y = -140 + 120 * cardIndex
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
	-- Change the only icon position, since only only one player can be dead per turn
	deadIcon.x = 25+playerIndex*100
	deadIcon.y = 20
	deadIcon.isVisible=true
	--TODO animation
end

function revivePlayer(playerIndex)
	players[playerIndex].dead=false
	deadIcon.isVisible=false
	--TODO animation
end

function positionPlayerIcon(playerIndex)
	-- Defines the first and last positions
	local firstY=700
	local lastY=400
	playersIcons[playerIndex].y=firstY-(firstY-lastY)*players[playerIndex].boardPosition/DISTANCEGOAL
end

--------------------------------------------------
--- Touch listeners
--------------------------------------------------

function cardTouch (event)
	local cardIndex = 0
	if (event.phase == "ended") then
		for i = 1, #cards do
			if (event.target == cards[i]) then
				cardIndex=i
				break
			end
		end
	end
	if cardIndex ~=0 then
		-- Selected card options at each step
		if step == STEP_SELECTCARD then
			-- Ignores if the card was already selected
			local alreadySelected = false
			for playerIndex = 1, playerCount do
				if players[playerIndex].card==cardIndex then alreadySelected=true end
			end
			if not alreadySelected then
				setPlayerCard(playerTurn,cardIndex)
				if nextPlayerTurn() then
					print("nextPlayerTurn")
					highlightPlayer(playerTurn)
				else
					killChoice()
				end
			end
		end
		return true
	end
end

function playerTouch (event)
	local playerIndex = 0
	if (event.phase == "ended") then
		for i = 1, playerCount do
			if (event.target == playersHUD[i]) then
				playerIndex = i
				break
			end
		end
	end
	if playerIndex ~= 0 then
		-- Selected player option at each step
		if step == STEP_KILLER then
			if playerIndex~=playerTurn then  -- Suicide isn't allowed
				killPlayer(playerIndex)
				-- Next step
				firstPlayer=playerTurn
				initializeActionTurn()
			end
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
		elseif step == STEP_MOVE then
			if playerIndex==playerTurn then
				movePlayerConsumingResources(playerIndex)
				-- TODO Maybe this will mess with the animation
				nextMove()
			end
		elseif step == STEP_NEWORDER then
			if playerIndex~=playerTurn then  -- Cannot choose yourself for the first in the next turn
				firstPlayer=playerIndex
				nextTurn()
			end
		end
		return true
	end
end

function passTouch (event)
	if (event.phase == "ended") then
		if step == STEP_MOVE then
			nextMove()
		end
	end
	return true
end