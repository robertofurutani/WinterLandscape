--Muda Anchor para Top Left
display.setDefault( "anchorX", 0.0 )
display.setDefault( "anchorY", 0.0 )

--
-- Definição dos display groups (camadas)
bg = display.newGroup()
botoesLayers = display.newGroup()
bgTabuleiro = display.newGroup()

-- Funcao que torna o botao vermelho ao touch
local function tintRed (evento)
	if (evento.phase == "began") then
		evento.target:setFillColor(1, 0, 0, 1)
	elseif (evento.phase == "ended") then
		evento.target:setFillColor(1, 1, 1, 1)
		if evento.target.id == "botao1p" then tapBotao1p() end
		if evento.target.id == "botao2p" then tapBotao2p() end
		if evento.target.id == "botao3p" then tapBotao3p() end
		if evento.target.id == "botao4p" then tapBotao4p() end
		if evento.target.id == "botao5p" then tapBotao5p() end
		if evento.target.id == "botaoComo" then tapBotaoComo() end
		if evento.target.id == "botaoCredito" then tapBotaoCredito() end
	end
end

--Funcoes de transição
--
function transFade (item, delay, tempo )
	 item.alpha=0
	 transition.to( item, {delay=delay, time=tempo, alpha=1, transition=easing.inOutQuad })
end

function transFade (item, delay, tempo, funcOnComplete )
	 item.alpha=0
	 transition.to( item, {delay=delay, time=tempo, alpha=1, transition=easing.inOutQuad, onComplete=funcOnComplete })
end


--BG  do Menu
function mostrarMenu()

	 background = display.newImageRect( bg,"bg.png", 1024, 768)
	
	 baseMenu = display.newImageRect( bg,"baseMenu.png", 1024, 768)

	 transFade( background, 500, 5000)

	 transFade( baseMenu, 0, 2000)

	--Botoes e suas transições
	local botao1p = display.newImageRect( botoesLayers, "botao1p.png", 53, 55 )
	botao1p.x = 625
	botao1p.y = 400
	transFade (botao1p, 800, 2000)
	botao1p.id = "botao1p"

	local botao2p = display.newImageRect( botoesLayers, "botao2p.png", 53, 55 )
	botao2p.x = 675
	botao2p.y = 400
	transFade (botao2p, 1000, 2000)
	botao2p.id = "botao2p"


	local botao3p = display.newImageRect( botoesLayers, "botao3p.png", 68, 55 )
	botao3p.x = 740
	botao3p.y = 402
	transFade (botao3p, 1200, 2000)
	botao3p.id = "botao3p"


	local botao4p = display.newImageRect( botoesLayers, "botao4p.png", 68, 55 )
	botao4p.x = 830
	botao4p.y = 402
	transFade (botao4p, 1400, 2000)
	botao4p.id = "botao4p"


	local botao5p = display.newImageRect( botoesLayers, "botao5p.png", 68, 55 )
	botao5p.x = 910
	botao5p.y = 401
	transFade (botao5p, 1600, 2500)
	botao5p.id = "botao5p"


	local botaoCredito = display.newImageRect( botoesLayers, "botaoCredito.png", 185, 48 )
	botaoCredito.x = 130
	botaoCredito.y = 720
	transFade (botaoCredito, 1800, 2000)
	botaoCredito.id = "botaoCredito"


	local botaoComo = display.newImageRect( botoesLayers, "botaoComo.png", 185, 48 )
	botaoComo.x = 300
	botaoComo.y = 720
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
	mostrarTabuleiro()
end

local function tapBotao2p ()
  print ("Botao 2 pressionado")
end

local function tapBotao3p ()
print ("Botao 3 pressionado")
end

local function tapBotao4p ()
print ("Botao 4 pressionado")
end

local function tapBotao5p ()
print ("Botao 5 pressionado")
end

local function tapBotaoComo ()
print ("Botao Como pressionado")
end

local function tapBotaoCredito ()
print ("Botao Credito pressionado")
end

function removeMenu()
	display.remove(bg)
    display.remove(botoesLayers)
end

function mostrarTabuleiro()

	local tabuleiro = display.newImageRect( bgTabuleiro,"tabuleiro_fundo.jpg", 1024, 768)
	transFade( tabuleiro, 0, 1000, removeMenu)
	
end

mostrarMenu()
