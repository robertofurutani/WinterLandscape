--AudioUtil module
local AudioUtil = {}

local SEDIR= "audio/se/"
local BGMDIR = "audio/bgm/"
--DON'T USE SE WITH SAME NAME AND DIFFERENT EXTENSIONS!
local WAVSETABLE = {"Die","human_fire"}
local MP3SETABLE = {"fallDamage"}

local lastMusic=nil

local function loadSETable()
	local seTable={}
	-- Put all sounds into a seTable. 
	for _,name in ipairs(WAVSETABLE) do -- Initialize wav sounds
		seTable[name] = audio.loadSound(SEDIR..name..".wav")
	end
	for _,name in ipairs(MP3SETABLE) do -- Initialize mp3 sounds
		seTable[name] = audio.loadSound(SEDIR..name..".mp3")
	end
	return seTable
end

local seTable=loadSETable()

function AudioUtil.getSETable()
	return seTable
end

function AudioUtil.playSE(nameWithoutExtension)
	audio.play(audio.loadSound(AudioUtil.getSETable()[nameWithoutExtension]))
end

-- Stops all the sound and plays the file name. Default plays at infinite looping
function AudioUtil.playBGM(nameIncludingExtension,loops)
	loops=loops or -1
	if lastMusic then 
		audio.dispose(lastMusic)
	end
	audio.stop()
	audio.setVolume(1.0,{channel=0})
	lastMusic=audio.loadStream(BGMDIR..nameIncludingExtension)
	audio.play(lastMusic,{loops=loops})
end

return AudioUtil