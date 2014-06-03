require("player")

local MAXPLAYERNUMBER = 5
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

-- Steps
STEP_SELECTCARD=1
STEP_KILLER=2
STEP_ACTION=3
STEP_MOVE=4
STEP_NEWORDER=5

-- Others
players = {}
firstPlayer=0
playerTurn=0
step=0
turnNumber=0 -- Test purposes

function initializeGame()
	-- Initialize player objects
	for i = 1, MAXPLAYERNUMBER do
		players[i]=Player.create(i)
	end
	
	-- Technically this button is only for the moveStep and actionStep
	passButton = display.newImageRect( playersHUDLayer, "botao5p.png", 53, 55 )
	passButton.x = 825
	passButton.y = 20
	transFade (passButton, 0, 1000)
	passButton.id = "passButton"
	passButton:addEventListener( "touch", passTouch)
	
	-- Main HUD
	mainHUDText = display.newText({text="",font=native.systemFont, fontSize=32})
	mainHUDText.x = 100
	mainHUDText.y = 730
	mainHUDText:setFillColor(0,0,0) 
	transFade (mainHUDText, 0, 1000)
	local mainHUDBarsPaths = {"barraYellow.png","barraBlue.png","barraPink.png","barraRed.png","barraGreen.png"}
	for i = 1, MAXPLAYERNUMBER do -- Draw all bar at the same positions, but only the right one will be visible
		mainHUDBars[i] = display.newImageRect( playersHUDLayer, mainHUDBarsPaths[i], 760, 1024 )
		mainHUDBars[i].x = 10
		mainHUDBars[i].y = 0
		mainHUDBars.isVisible = false
		transFade (mainHUDBars[i], 0, 1000)
	end
	
	-- Birds/Fish counter
	for i = 1, MAXPLAYERNUMBER do
		playersHUDBirds[i] = display.newText({text="0",font=native.systemFont, fontSize=16})
		playersHUDFish[i] = display.newText({text="0",font=native.systemFont, fontSize=16})
		playersHUDBirds[i]:setFillColor(0,0,0) 
		playersHUDFish[i]:setFillColor(0,0,0) 
		transFade (playersHUDBirds[i], 0, 1000)
		transFade (playersHUDFish[i], 0, 1000)
	end
	playersHUDBirds[1].x = 125
	playersHUDBirds[1].y = 300
	playersHUDBirds[2].x = 225
	playersHUDBirds[2].y = 300
	playersHUDBirds[3].x = 325
	playersHUDBirds[3].y = 300
	playersHUDBirds[4].x = 425
	playersHUDBirds[4].y = 300
	playersHUDBirds[5].x = 525
	playersHUDBirds[5].y = 300
	playersHUDFish[1].x = 150
	playersHUDFish[1].y = 300
	playersHUDFish[2].x = 250
	playersHUDFish[2].y = 300
	playersHUDFish[3].x = 350
	playersHUDFish[3].y = 300
	playersHUDFish[4].x = 450
	playersHUDFish[4].y = 300
	playersHUDFish[5].x = 550
	playersHUDFish[5].y = 300
	
	-- Players HUD
	playersHUD[1] = display.newImageRect( playersHUDLayer, "botao1p.png", 53, 55 )
	playersHUD[1].x = 125
	playersHUD[1].y = 200
	transFade (playersHUD[1], 0, 1000)
	playersHUD[1].id = "playersHUD1"
	playersHUD[1]:addEventListener( "touch", playerTouch)
	
	playersHUD[2] = display.newImageRect( playersHUDLayer, "botao2p.png", 53, 55 )
	playersHUD[2].x = 225
	playersHUD[2].y = 200
	transFade (playersHUD[2], 0, 1000)
	playersHUD[2].id = "playersHUD2"
	playersHUD[2]:addEventListener( "touch", playerTouch)
	
	playersHUD[3] = display.newImageRect( playersHUDLayer, "botao3p.png", 53, 55 )
	playersHUD[3].x = 325
	playersHUD[3].y = 200
	transFade (playersHUD[3], 0, 1000)
	playersHUD[3].id = "playersHUD3"
	playersHUD[3]:addEventListener( "touch", playerTouch)
	
	playersHUD[4] = display.newImageRect( playersHUDLayer, "botao4p.png", 53, 55 )
	playersHUD[4].x = 425
	playersHUD[4].y = 200
	transFade (playersHUD[4], 0, 1000)
	playersHUD[4].id = "playersHUD4"
	playersHUD[4]:addEventListener( "touch", playerTouch)
	
	playersHUD[5] = display.newImageRect( playersHUDLayer, "botao5p.png", 53, 55 )
	playersHUD[5].x = 525
	playersHUD[5].y = 200
	transFade (playersHUD[5], 0, 1000)
	playersHUD[5].id = "playersHUD5"
	playersHUD[5]:addEventListener( "touch", playerTouch)
	
	-- Players Icon
	playersIcons[1] = display.newImageRect( playersHUDLayer, "playerYellow.png", 19, 35 )
	playersIcons[1].x = 125
	transFade (playersIcons[1], 0, 1000)
	playersIcons[1].id = "playersIcons1"
	
	playersIcons[2] = display.newImageRect( playersHUDLayer, "playerBlue.png", 19, 35 )
	playersIcons[2].x = 225
	transFade (playersIcons[2], 0, 1000)
	playersIcons[2].id = "playersIcons2"
	
	playersIcons[3] = display.newImageRect( playersHUDLayer, "playerPink.png", 19, 35 )
	playersIcons[3].x = 325
	transFade (playersIcons[3], 0, 1000)
	playersIcons[3].id = "playersIcons3"
	
	playersIcons[4] = display.newImageRect( playersHUDLayer, "playerRed.png", 19, 35 )
	playersIcons[4].x = 425
	transFade (playersIcons[4], 0, 1000)
	playersIcons[4].id = "playersIcons4"
	
	playersIcons[5] = display.newImageRect( playersHUDLayer, "playerGreen.png", 19, 35 )
	playersIcons[5].x = 525
	transFade (playersIcons[5], 0, 1000)
	playersIcons[5].id = "playersIcons5"
	
	for i = 1, MAXPLAYERNUMBER do -- define icon y
		positionPlayerIcon(i)
	end
	
	-- Cards image
	cards[CARTA_CACADOR] = display.newImageRect( playersHUDLayer, "cartaCacadorFrente.png", 142, 190 )
	transFade (cards[CARTA_CACADOR], 0, 1000)
	cards[CARTA_CACADOR].id = "cartaCacador"
	cards[CARTA_CACADOR]:addEventListener( "touch", cardTouch)
	positionNonPlayerCard(CARTA_CACADOR)
	
	cards[CARTA_PESCADOR] = display.newImageRect( playersHUDLayer, "cartaPescadorFrente.png", 142, 190 )
	transFade (cards[CARTA_PESCADOR], 0, 1000)
	cards[CARTA_PESCADOR].id = "cartaPescador"
	cards[CARTA_PESCADOR]:addEventListener( "touch", cardTouch)
	positionNonPlayerCard(CARTA_PESCADOR)
	
	cards[CARTA_PATINADOR] = display.newImageRect( playersHUDLayer, "cartaPatinadorFrente.png", 142, 190 )
	transFade (cards[CARTA_PATINADOR], 0, 1000)
	cards[CARTA_PATINADOR].id = "cartaPatinador"
	cards[CARTA_PATINADOR]:addEventListener( "touch", cardTouch)
	positionNonPlayerCard(CARTA_PATINADOR)
	
	cards[CARTA_DIABO] = display.newImageRect( playersHUDLayer, "cartaDiaboFrente.png", 142, 190 )
	transFade (cards[CARTA_DIABO], 0, 1000)
	cards[CARTA_DIABO].id = "cartaDiabo"
	cards[CARTA_DIABO]:addEventListener( "touch", cardTouch)
	positionNonPlayerCard(CARTA_DIABO)
	
	cards[CARTA_CORVO] = display.newImageRect( playersHUDLayer, "cartaCorvoFrente.png", 142, 190 )
	transFade (cards[CARTA_CORVO], 0, 1000)
	cards[CARTA_CORVO].id = "cartaCorvo"
	cards[CARTA_CORVO]:addEventListener( "touch", cardTouch)
	positionNonPlayerCard(CARTA_CORVO)
	
	cards[CARTA_LADRAO] = display.newImageRect( playersHUDLayer, "cartaLadraoFrente.png", 142, 190 )
	transFade (cards[CARTA_LADRAO], 0, 1000)
	cards[CARTA_LADRAO].id = "cartaLadrao"
	cards[CARTA_LADRAO]:addEventListener( "touch", cardTouch)
	positionNonPlayerCard(CARTA_LADRAO)
	
	-- Dead Icon
	deadIcon = display.newImageRect( playersHUDLayer, "botaoRecusar.png", 193, 193 )
	deadIcon.isVisible = false
	transFade (deadIcon, 0, 1000)
	
	firstPlayer=math.random(5)
	nextTurn()
end

function nextTurn()
	-- TODO animation for next turn
	step = STEP_SELECTCARD
	turnNumber=turnNumber+1
	print("turnNumber="..turnNumber)
	-- Remove the card and revives everyone
	for i = 1, MAXPLAYERNUMBER do
		removePlayerCard(i)
		if players[i].dead then revivePlayer(i) end
	end
	playerTurn=firstPlayer
	highlightPlayer(playerTurn)
end

-- If a player have the right card, he call kill someone. Else go to the next step. Return if there is a killer among us
function killChoice()
	for i = 1, MAXPLAYERNUMBER do
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
	highlightPlayer(playerTurn)
end

function initializeActionTurn()
	-- Give bird to everyone
	for i = 1, MAXPLAYERNUMBER do
		birdsReceived = players[i].card==CARTA_CACADOR and 2 or 1 
		setPlayerBirds(i,players[i].birds+birdsReceived)
	end
	print("Resource gain step (birds)")
	--TODO animation
	step = STEP_ACTION
	print("actionStep STARTED")
end

function nextAction()
	print("nextAction")
	if nextPlayerTurn() then
		if players[playerTurn].dead then
			nextAction()
		else
			highlightPlayer(playerTurn)
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
	if nextPlayerTurn() then
		if players[playerTurn].dead or players[playerTurn].card==CARTA_LADRAO or players[playerTurn].card==CARTA_PATINADOR then
			nextMove()
		else
			highlightPlayer(playerTurn)
		end
	else
		local playerThatDefinesNewOrderIndex = 0
		for i = 1, MAXPLAYERNUMBER do
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

function declareVictory(playerIndex)
	--TODO something
	print("Player "..playerIndex.." wins!!!")
	--TODO return to title screen
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
	--TODO animation
	positionPlayerIcon(playerIndex)
	if(players[playerIndex].boardPosition>=DISTANCEGOAL) then declareVictory(playerIndex) end
	players[playerIndex]:printStatus() -- Debug purposes
end	

-- Set variable playerTurn to the next player. Returns false if the next player and the first player are equal (the cicle is complete).
function nextPlayerTurn()
	playerTurn = playerTurn==MAXPLAYERNUMBER and 1 or playerTurn+1
	return ( firstPlayer ~= playerTurn )
end

--------------------------------------------------
--- Main text HUD
--------------------------------------------------
function refreshMainHUDText()
	local text="Jogador "..playerTurn..": "
	textStep={
		[STEP_SELECTCARD]="Selecione sua carta.",
		[STEP_KILLER]="Selecione quem será morto.",
		[STEP_ACTION]="Usar sua ação?",  -- TODO improve this
		[STEP_MOVE]="Andar?",
		[STEP_NEWORDER]="Escolha o primeiro jogador do próximo turno."
	}
	text=text..textStep[step]
	mainHUDText.text=text
	-- Displays the right bar
	for i = 1, MAXPLAYERNUMBER do
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
	for i = 1, MAXPLAYERNUMBER do
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
			for playerIndex = 1, MAXPLAYERNUMBER do
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
			print("index="..cardIndex)
		end
	end
end

function playerTouch (event)
	local playerIndex = 0
	if (event.phase == "ended") then
		for i = 1, MAXPLAYERNUMBER do
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
				nextAction()
			end
		elseif step == STEP_ACTION then
			if playerIndex==playerTurn then -- Clicked in yourself
				if players[playerIndex].card==CARTA_PESCADOR then	-- Transform bird into fish !
					setPlayerFish(playerIndex,players[playerIndex].fish+players[playerIndex].birds)
					setPlayerBirds(playerIndex,0)
					-- TODO Maybe this will mess with the animation
					nextAction()
				elseif players[playerIndex].card==CARTA_PATINADOR then
					movePlayerConsumingResources(playerIndex, true)
					nextAction()
				end
			else
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
		players[playerIndex]:printStatus() -- Debug purposes
	end
end

function passTouch (event)
	if (event.phase == "ended") then
		if step == STEP_ACTION then
			nextAction()
		elseif step == STEP_MOVE then
			nextMove()
		end
	end
end