--AudioUtil module
local AudioUtil = {}

local SEDIR= "audio/se/"
local BGMDIR = "audio/bgm/"

local lastMusic=nil
local seTable={}

-- If the SE is new, add at seTable for future use
function AudioUtil.playSE(nameWithExtension)
	if seTable[nameWithExtension]==nil then seTable[nameWithExtension] = audio.loadSound(SEDIR..nameWithExtension) end
	   audio.play(seTable[nameWithExtension])
end

-- Stops all the sound and plays the file name. Default plays at infinite looping
function AudioUtil.playBGM(nameIncludingExtension,loops)
	loops=loops or -1
	audio.stop()
	if lastMusic then 
		audio.dispose(lastMusic)
	end
	audio.setVolume(1.0,{channel=0})
	lastMusic=audio.loadStream(BGMDIR..nameIncludingExtension)
	audio.play(lastMusic,{loops=loops})
end

return AudioUtil