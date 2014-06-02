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
cards = {}

-- Steps
-- TODO use numbers rather than booleans ?
selectCardsStep=false
killerStep=false
actionStep=false
moveStep=false
newOrderStep=false

-- Others
players = {}
firstPlayer=0
playerTurn=0
turnNumber=0 -- Test purposes

function initializeGame()
	-- Technically this button is only for the moveStep and actionStep
	passButton = display.newImageRect( playersHUDLayer, "botao1p.png", 53, 55 )
	passButton.x = 425
	passButton.y = 200
	transFade (passButton, 0, 1000)
	passButton.id = "passButton"
	passButton:addEventListener( "touch", passTouch)
	
	playersHUD[1] = display.newImageRect( playersHUDLayer, "botao1p.png", 53, 55 )
	playersHUD[1].x = 225
	playersHUD[1].y = 400
	transFade (playersHUD[1], 0, 1000)
	playersHUD[1].id = "playersHUD1"
	playersHUD[1]:addEventListener( "touch", playerTouch)
	
	playersHUD[2] = display.newImageRect( playersHUDLayer, "botao2p.png", 53, 55 )
	playersHUD[2].x = 325
	playersHUD[2].y = 400
	transFade (playersHUD[2], 0, 1000)
	playersHUD[2].id = "playersHUD2"
	playersHUD[2]:addEventListener( "touch", playerTouch)
	
	playersHUD[3] = display.newImageRect( playersHUDLayer, "botao3p.png", 53, 55 )
	playersHUD[3].x = 425
	playersHUD[3].y = 400
	transFade (playersHUD[3], 0, 1000)
	playersHUD[3].id = "playersHUD3"
	playersHUD[3]:addEventListener( "touch", playerTouch)
	
	playersHUD[4] = display.newImageRect( playersHUDLayer, "botao4p.png", 53, 55 )
	playersHUD[4].x = 525
	playersHUD[4].y = 400
	transFade (playersHUD[4], 0, 1000)
	playersHUD[4].id = "playersHUD4"
	playersHUD[4]:addEventListener( "touch", playerTouch)
	
	playersHUD[5] = display.newImageRect( playersHUDLayer, "botao5p.png", 53, 55 )
	playersHUD[5].x = 625
	playersHUD[5].y = 400
	transFade (playersHUD[5], 0, 1000)
	playersHUD[5].id = "playersHUD5"
	playersHUD[5]:addEventListener( "touch", playerTouch)
	
	cards[CARTA_CACADOR] = display.newImageRect( playersHUDLayer, "botao1p.png", 53, 55 )
	cards[CARTA_CACADOR].x = 125
	cards[CARTA_CACADOR].y = 600
	transFade (cards[CARTA_CACADOR], 0, 1000)
	cards[CARTA_CACADOR].id = "cartaCacador"
	cards[CARTA_CACADOR]:addEventListener( "touch", cardTouch)
	
	cards[CARTA_PESCADOR] = display.newImageRect( playersHUDLayer, "botao1p.png", 53, 55 )
	cards[CARTA_PESCADOR].x = 225
	cards[CARTA_PESCADOR].y = 600
	transFade (cards[CARTA_PESCADOR], 0, 1000)
	cards[CARTA_PESCADOR].id = "cartaPescador"
	cards[CARTA_PESCADOR]:addEventListener( "touch", cardTouch)
	
	cards[CARTA_PATINADOR] = display.newImageRect( playersHUDLayer, "botao1p.png", 53, 55 )
	cards[CARTA_PATINADOR].x = 325
	cards[CARTA_PATINADOR].y = 600
	transFade (cards[CARTA_PATINADOR], 0, 1000)
	cards[CARTA_PATINADOR].id = "cartaPatinador"
	cards[CARTA_PATINADOR]:addEventListener( "touch", cardTouch)
	
	cards[CARTA_DIABO] = display.newImageRect( playersHUDLayer, "botao1p.png", 53, 55 )
	cards[CARTA_DIABO].x = 425
	cards[CARTA_DIABO].y = 600
	transFade (cards[CARTA_DIABO], 0, 1000)
	cards[CARTA_DIABO].id = "cartaDiabo"
	cards[CARTA_DIABO]:addEventListener( "touch", cardTouch)
	
	cards[CARTA_CORVO] = display.newImageRect( playersHUDLayer, "botao1p.png", 53, 55 )
	cards[CARTA_CORVO].x = 525
	cards[CARTA_CORVO].y = 600
	transFade (cards[CARTA_CORVO], 0, 1000)
	cards[CARTA_CORVO].id = "cartaCorvo"
	cards[CARTA_CORVO]:addEventListener( "touch", cardTouch)
	
	cards[CARTA_LADRAO] = display.newImageRect( playersHUDLayer, "botao1p.png", 53, 55 )
	cards[CARTA_LADRAO].x = 625
	cards[CARTA_LADRAO].y = 600
	transFade (cards[CARTA_LADRAO], 0, 1000)
	cards[CARTA_LADRAO].id = "cartaLadrao"
	cards[CARTA_LADRAO]:addEventListener( "touch", cardTouch)
	
	for i = 1, MAXPLAYERNUMBER do
		players[i]=Player.create(i)
	end
	
	firstPlayer=math.random(5)
	nextTurn()
end

function nextTurn()
	-- TODO animation for next turn
	selectCardsStep=true
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
			killerStep=true
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
	actionStep=true
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
		actionStep=false
		moveStep=true
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
		moveStep=false
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
			newOrderStep=true
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
	--TODO update birds and fish counters
	movePlayerEffects(playerIndex,distance)
end

-- Only check victory conditions and plays the animation
function movePlayerEffects(playerIndex,distance)
	--TODO animation
	if(players[playerIndex].boardPosition>=DISTANCEGOAL) then declareVictory(playerIndex) end
	players[playerIndex]:printStatus() -- Debug purposes
end	

-- Set variable playerTurn to the next player. Returns false if the next player and the first player are equal (the cicle is complete).
function nextPlayerTurn()
	playerTurn = playerTurn==MAXPLAYERNUMBER and 1 or playerTurn+1
	return ( firstPlayer ~= playerTurn )
end

--------------------------------------------------
--- Functions that change visual/player things
--------------------------------------------------

-- Implement these methods at player object ?

-- Highlight the player. When param<1 or there is no param = No Highlight 
-- Highlight in red.
function highlightPlayer(playerIndex)
	local selectedIndex = playerIndex or 0
	for i = 1, MAXPLAYERNUMBER do
		if i==selectedIndex then playersHUD[i]:setFillColor(1, 0, 0, 1) else playersHUD[i]:setFillColor(1, 1, 1, 1) end
	end
end

function setPlayerCard(playerIndex,card)
	players[playerIndex].card=card
	--TODO Visual card positioning
end

function removePlayerCard(playerIndex)
	players[playerIndex].card=0
	--TODO Visual card positioning
end

function setPlayerBirds(playerIndex, birds)
	players[playerIndex].birds = birds
	--TODO Visual icon positioning
end

function setPlayerFish(playerIndex, fish)
	players[playerIndex].fish = fish
	--TODO Visual icon positioning
end

function killPlayer(playerIndex)
	players[playerIndex].dead=true
	--TODO animation and icon
end

function revivePlayer(playerIndex)
	players[playerIndex].dead=false
	--TODO Visual icon positioning
end

--------------------------------------------------
--- Touch listeners
--------------------------------------------------

function cardTouch (event)
	cardIndex = 0
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
		if selectCardsStep then
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
					selectCardsStep=false
					killChoice()
				end
			end
			print("index="..cardIndex)
		end
	end
end

function playerTouch (event)
	playerIndex = 0
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
		if killerStep then
			if playerIndex~=playerTurn then  -- Suicide isn't allowed
				killPlayer(playerIndex)
				-- Next step
				killerStep=false
				firstPlayer=playerTurn
				initializeActionTurn()
				nextAction()
			end
		elseif actionStep then
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
		elseif moveStep then
			if playerIndex==playerTurn then
				movePlayerConsumingResources(playerIndex)
				-- TODO Maybe this will mess with the animation
				nextMove()
			end
		elseif newOrderStep then
			if playerIndex~=playerTurn then  -- Cannot choose yourself for the first in the next turn
				firstPlayer=playerIndex
				newOrderStep=false
				nextTurn()
			end
		end
		players[playerIndex]:printStatus() -- Debug purposes
	end
end

function passTouch (event)
	if (event.phase == "ended") then
		if actionStep then
			nextAction()
		elseif moveStep then
			nextMove()
		end
	end
end