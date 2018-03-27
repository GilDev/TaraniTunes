-- TaraniTunes
-- http://github.com/GilDev/TaraniTunes
-- By GilDev
-- http://gildev.tk

-- CONFIG --

local specialFunctionId = 30 -- This special function will be reserved: 1 for SF1, 2 for SF2…

-- You NEED to use logical switches to manipulate TaraniTunes.

-- WARNING: If you use trims for changing songs for example (and I recommand you do),
-- you need to deactivate the "real" trim functions of the model, to do this,
-- go into "FLIGHT MODES" configuration, go to each flight mode you use for your model
-- and set the throttle "Trims" value (the third if you use the default AETR mode) to "--".

-- Here's how to setup the play switch to SD centered:
-- LOGICAL SWITCH  L61
-- Func   OR
-- V1     SD-
-- V2     SD-
-- Then set playSongLogicalSwitch to 61 below.

-- Here's how to setup the next song switch to throttle trim down:
-- LOGICAL SWITCH  L62
-- Func   OR
-- V1     tTd
-- V2     tTd
-- Then set nextSongLogicalSwitch to 62 below.

local playSongLogicalSwitch   = 61 -- Logical switch that will play the current song
local nextSongLogicalSwitch   = 62 -- Logical switch that will set the current song to the next one
local prevSongLogicalSwitch   = 63 -- Logical switch that will set the current song to the previous one
local randomSongLogicalSwitch = 64 -- Logical switch that will set the current song to a random one

-- DON'T EDIT BELOW THIS LINE --

loadScript("/SOUNDS/playlist.lua")() -- Import playlist

local errorOccured = false
local screenUpdate = true
local nextScreenUpdate = false

local playingSong = 1
local selection = 1

local songChanged = false
local resetDone = false

local function error(strings)
	errorStrings = strings
	errorOccured = true
end

function playSong()
	model.setCustomFunction(
		specialFunctionId,
		{
			switch = playSongSwitchId,
			func = 16,
			name = playlist[playingSong][2]
		}
	)
end

function resetSong()
	model.setCustomFunction(
		specialFunctionId,
		{
			switch = -playSongSwitchId
		}
	)
end

local function init()
	-- Calculate indexes
	specialFunctionId  = specialFunctionId - 1 -- SF1 is at index 0 and so on
	if LCD_W == 212 then -- if Taranis X9D
		playSongSwitchId = 50 + playSongLogicalSwitch
	else -- if Taranis Q X7
		playSongSwitchId = 38 + playSongLogicalSwitch
	end
	nextSongSwitchId   = getFieldInfo("ls" .. nextSongLogicalSwitch).id
	prevSongSwitchId   = getFieldInfo("ls" .. prevSongLogicalSwitch).id
	randomSongSwitchId = getFieldInfo("ls" .. randomSongLogicalSwitch).id
	
	nextScreenUpdate = true
	screenUpdate = true
	songChanged = true
end

nextSongSwitchPressed   = false;
prevSongSwitchPressed   = false;
randomSongSwitchPressed = false;

local function background()

	model.setLogicalSwitch(59,{func=6,v1=230,v2=playlist[playingSong][3]}) --updates the logical swicth according to the current song selected
	
	if resetDone then
		playSong()
		resetDone = false
	end
	
	if songChanged then
		resetSong()
		songChanged = false
		resetDone = true
	end

	-- Next song
	if getValue(nextSongSwitchId) > 0 then
		if not nextSongSwitchPressed then
			nextSongSwitchPressed = true
			nextScreenUpdate = true
			songChanged = true
			screenUpdate = true
			if playingSong == #playlist then
				playingSong = 1
			else
				playingSong = playingSong + 1
			end
		end
	else
		nextSongSwitchPressed = false
	end

	-- Previous song
	if getValue(prevSongSwitchId) > 0 then
		if not prevSongSwitchPressed then
			prevSongSwitchPressed = true
			nextScreenUpdate = true
			songChanged = true
			screenUpdate = true
			if playingSong == 1 then
				playingSong = #playlist
			else
				playingSong = playingSong - 1
			end
		end
	else
		prevSongSwitchPressed = false
	end

	-- Random song
	if getValue(randomSongSwitchId) > 0 then
		if not randomSongSwitchPressed then
			randomSongSwitchPressed = true
			playingSong = math.random (1, #playlist)
			songChanged = true
			screenUpdate = true
			nextScreenUpdate = true
		end
	else
		randomSongSwitchPressed = false
	end
end

local function run(event)
	-- INPUT HANDLING --
	if (event == EVT_ROT_RIGHT or event == EVT_MINUS_FIRST or event == EVT_MINUS_RPT) then
		if selection == #playlist then
			selection = 1
		else
			selection = selection + 1
		end

		screenUpdate = true
	elseif (event == EVT_ROT_LEFT or event == EVT_PLUS_FIRST or event == EVT_PLUS_RPT) then
		if selection == 1 then
			selection = #playlist
		else
			selection = selection - 1
		end

		screenUpdate = true
	elseif event == EVT_ROT_BREAK or event == EVT_ENTER_BREAK then -- Play selected song
		playingSong = selection
		songChanged = true
		screenUpdate = true
	elseif nextScreenUpdate then
		selection = playingSong
		nextScreenUpdate = false
	end

	-- DRAWING --
	if screenUpdate or event == 191 then -- 191 is the event code when entering the telemetry screen
		screenUpdate = false

		lcd.clear();

		-- Title
		lcd.drawText(1, 1, "TaraniTunes", MIDSIZE)
		lcd.drawText(LCD_W - 19, 1, "By", SMLSIZE)
		lcd.drawText(LCD_W - 27, 9, "GilDev", SMLSIZE)

		-- Separator
		lcd.drawLine(0, 16, LCD_W - 1, 16, SOLID, FORCE)

		-- Print error
		if errorOccured then
			yLine = {18, 26, 34, 42, 50}
			for i = 1, #errorStrings do
				lcd.drawText(1, yLine[i], errorStrings[i])
			end

			return
		end

		-- Now playing
		lcd.drawText(1, 18, string.char(62) .. playlist[playingSong][1])

		-- Separator
		lcd.drawLine(0, 26, LCD_W - 1, 26, DOTTED, FORCE)

		-- Song selector
		if playlist[selection - 2] then lcd.drawText(1, 28, playlist[selection - 2][1], SMLSIZE) end
		if playlist[selection - 1] then lcd.drawText(3, 35, playlist[selection - 1][1], SMLSIZE) end
		if playlist[selection]     then lcd.drawText(1, 42, string.char(126) .. playlist[selection][1], SMLSIZE) end
		if playlist[selection + 1] then lcd.drawText(3, 49, playlist[selection + 1][1], SMLSIZE) end
		if playlist[selection + 2] then lcd.drawText(1, 56, playlist[selection + 2][1], SMLSIZE) end
	end
end

return {run = run, background = background, init = init}
