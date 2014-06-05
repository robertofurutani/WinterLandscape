require("efeitos")
require("classes")
require("game")

--Muda Anchor para Top Left
display.setDefault( "anchorX", 0.0 )
display.setDefault( "anchorY", 0.0 )

--
-- Definição dos display groups (camadas)
bg = display.newGroup()
botoesLayers = display.newGroup()
gameLayer = nil
victoryLayer = nil
bgCredito = display.newGroup()
bgComoJogar = display.newGroup()

-- Funcao que torna o botao vermelho ao touch
local function tintRed (evento)
	if (evento.phase == "began") then
		evento.target:setFillColor(1, 0, 0, 1)
	elseif (evento.phase == "ended") then
		evento.target:setFillColor(1, 1, 1, 1)
		if evento.target.id == "botao1p" then tapBotao1p(); print("tapBotao1p()") end
		if evento.target.id == "botao2p" then tapBotao2p() end
		if evento.target.id == "botao3p" then tapBotao3p() end
		if evento.target.id == "botao4p" then tapBotao4p() end
		if evento.target.id == "botao5p" then tapBotao5p() end
		if evento.target.id == "botaoComo" then tapBotaoComo() end
		if evento.target.id == "botaoCredito" then tapBotaoCredito() end
	end
end


--BG  do Menu
function mostrarMenu()
	bgCredito.alpha = 0
	bgComoJogar.alpha = 0
	bg.alpha = 1
	botoesLayers.alpha = 1
end

function inicializar()
	mostrarMenu()

	background = display.newImageRect( bg,"bg.png", 768, 1024)
	
	baseMenu = display.newImageRect( bg,"baseMenu.png", 768, 1024)

	transFade( background, 5000, 500)

	transFade( baseMenu, 2000, 0)

	--Botoes e suas transições
	local botao1p = display.newImageRect( botoesLayers, "botao1p.png", 55, 53 )
	botao1p.x = 400
	botao1p.y = 625
	transFade (botao1p, 800, 2000)
	botao1p.id = "botao1p"

	local botao2p = display.newImageRect( botoesLayers, "botao2p.png", 55, 53 )
	botao2p.x = 400
	botao2p.y = 675
	transFade (botao2p, 1000, 2000)
	botao2p.id = "botao2p"


	local botao3p = display.newImageRect( botoesLayers, "botao3p.png", 55, 68 )
	botao3p.x = 402 
	botao3p.y = 740
	transFade (botao3p, 1200, 2000)
	botao3p.id = "botao3p"


	local botao4p = display.newImageRect( botoesLayers, "botao4p.png", 55, 68 )
	botao4p.x = 402
	botao4p.y = 830
	transFade (botao4p, 1400, 2000)
	botao4p.id = "botao4p"


	local botao5p = display.newImageRect( botoesLayers, "botao5p.png", 55, 68 )
	botao5p.x = 401
	botao5p.y = 910
	transFade (botao5p, 1600, 2500)
	botao5p.id = "botao5p"


	local botaoCredito = display.newImageRect( botoesLayers, "botaoCredito.png", 48, 185)
	botaoCredito.x = 720
	botaoCredito.y = 130 
	transFade (botaoCredito, 1800, 2000)
	botaoCredito.id = "botaoCredito"


	local botaoComo = display.newImageRect( botoesLayers, "botaoComo.png", 48, 185 )
	botaoComo.x = 720
	botaoComo.y = 300
	transFade (botaoComo, 1800, 2000)
	botaoComo.id = "botaoComo"

	--Listeners
	botao1p:addEventListener( "touch", tintRed)
	botao2p:addEventListener( "touch", tintRed)
	botao3p:addEventListener( "touch", tintRed)
	botao4p:addEventListener( "touch", tintRed)
	botao5p:addEventListener( "touch", tintRed)
	botaoCredito:addEventListener( "touch", tintRed)
	botaoComo:addEventListener( "touch", tintRed)
end

--Funcoes dos Botões
function tapBotao1p()
	esconderMenu()
	initializeGame(1,esconderMenu)
end

function tapBotao2p ()
  print ("Botao 2 pressionado")
	esconderMenu()
	initializeGame(2,esconderMenu)
end

function tapBotao3p ()
print ("Botao 3 pressionado")
	esconderMenu()
	initializeGame(3,esconderMenu)
end

function tapBotao4p ()
print ("Botao 4 pressionado")
	esconderMenu()
	initializeGame(4,esconderMenu)
end

function tapBotao5p ()
print ("Botao 5 pressionado")
	esconderMenu()
	initializeGame(5,esconderMenu)
end

function tapBotaoComo ()
	mostrarComoJogar()
end

function tapBotaoCredito ()
 	mostrarCreditos()
end

function esconderMenu()
	bg.alpha = 0
	botoesLayers.alpha = 0
end

function mostrarComoJogar()
    bgComoJogar.alpha = 1
	local imgComoJogar = display.newImageRect( bgComoJogar,"comojogar.png", 768, 1024)
	local btVoltar = display.newImageRect(bgComoJogar, "voltar.jpg", 200, 100 )
	btVoltar.x = 300
	btVoltar.y = 900
	
	btVoltar.id = "btVoltar"
	transFade( imgComoJogar, 0, 500, esconderMenu)
	transFade( btVoltar, 0, 500)
	print("mostrarComoJogar")
	btVoltar:addEventListener( "touch", mostrarMenu)
end

function mostrarCreditos()
	bgCredito.alpha = 1
	local imgCreditos = display.newImageRect( bgCredito,"creditos.png",  768, 1024)
	local btVoltar = display.newImageRect(bgCredito, "voltar.jpg", 200, 100 )
	btVoltar.x = 300
	btVoltar.y = 900
	
	btVoltar.id = "btVoltar"
	transFade( imgCreditos, 0, 500, esconderMenu)
	transFade( btVoltar, 0, 500)
	
	btVoltar:addEventListener( "touch", mostrarMenu)
end


inicializar()
