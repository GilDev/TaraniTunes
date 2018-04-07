--[[ 
 TaraniTunes
 Version 2.1
  http://github.com/GilDev/TaraniTunes
 By GilDev
 http://gildev.tk

--Main File--

See the README file for setting up the playlist.lua file locations and structure

----Setting up the Transmitter----	
							
!!You NEED to use logical switches to manipulate TaraniTunes!!

 WARNING: If you use trims for changing songs (and I recommend you do),
 you need to deactivate the "real" trim functions on the trims you plan 
 to use for manipulating TaraniTunes. 
 To do this, go into "FLIGHT MODES" configuration, go to each flight mode 
 you use for your model and set the appropriate "Trims" value to "--"   
 (Throttle trims are in the example).
 
 Here's a sample setup of the logical switches (LS61 thru LS64) you need to setup on your transmitter
 
  SWITCH  Func  V1	V2
  LS61 	 OR	SD-	SD↑ (**Explanation under this example)
  LS62	 OR	tTd	tTd (LS62 plays next song)
  LS63	 OR	tTu	tTu (LS63 plays previous song)
  LS64	 OR	SD↓	SD↓ (LS64 plays random song)
 
**Using the Example above 
SD↑ will "Pause" the song and Timer3
SD- will "Play" the music
SD↓ will play a "Random" song and reset timer3  

----Additional Functions/Information-----
Since everything in the OpenTX is user programmable
You need to enter the switch number to "Pause" the song and
what switch you have choosen your "Random" Song switch

Here are the numbers for the switches 
Replace the values in "pause" and "randomS"(below) with the appropriate number

SA↑=1, SA-=2, SA↓=3, SB↑=4, SB-=5, SB↓=6, SC↑=7, SC-=8, SC↓=9, 
SD↑=10, SD-=11, SD↓=12, SE↑=13, SE-=14, SE↓=15, SF↑=16, SF↓=17, 
SG↑=18, SG-=19, SG↓=20, SH↑=21, SH↓=22       --]]

local pause =10  --Enter the switch number you will used to "Pause" the music
		 --Set the trigger for timer3 in your Model Setup to match this switch
local randomS =12 -- Inserts the "Reset Timer3" according to your switch assignment			
--[[            
LS60 will list the song length of the currently playing song 
	This is updated automatically, you do not have to enter the values.

BGMusic|| (pause) will be placed on SF32.
	This will be automatically inserted based on the information you listed above.
	
If you do not want all of the playlists options 
Change the directory to read a previous playlist from the available options 
	Example: You only want 2 play lists then change: 
	script3 to read "/1/playlist.lua" and script4 to read "/2/playlist.lua"
--]]
local script1 = "/1/playlist.lua"  -- path to playlist 1
local script2 = "/2/playlist.lua"  -- path to playlist 2
local script3 = "/3/playlist.lua"  -- path to playlist 2
local script4 = "/4/playlist.lua"  -- path to playlist 4

-- DON'T EDIT BELOW THIS LINE --

-- locals

local specialFunctionId = 30 -- This special function will be reserved
			     --  SF31 and SF32 will also be reserved
local playSongLogicalSwitch   = 61 -- Logical switch that will play the current song
local nextSongLogicalSwitch   = 62 -- Logical switch that will set the current song to the next one
local prevSongLogicalSwitch   = 63 -- Logical switch that will set the current song to the previous one
local randomSongLogicalSwitch = 64 -- Logical switch that will set the current song to a random one
local errorOccured = false
local screenUpdate = true
local nextScreenUpdate = false
local playingSong = 1
local selection = 1
local songChanged = false
local resetDone = false

 -- control functions
local function error(strings)
	errorStrings = strings
	errorOccured = true
end

function playSong()
	model.setCustomFunction(specialFunctionId,{switch = playSongSwitchId,func = 16,
			name = playlist[playingSong][2]})
end

function resetSong()
	model.setCustomFunction(specialFunctionId,{switch = -playSongSwitchId})
end

--script trigger
  if set1 == 4 then 
  set2 = script1 else
  if set1 == 3 then 
  set2 = script2 else
  if set1 == 2 then 
  set2 = script3 else
  set2 = script4
  end
  end
  end   

loadScript("/SOUNDS/lists"..set2)()	--load new script values

-- set initial variables
nextSongSwitchPressed   = false;
prevSongSwitchPressed   = false;
randomSongSwitchPressed = false;

--background
local function background()
--2 functions to autoupdates the logical swicth according to the current song selected
	model.setLogicalSwitch(59,{func=3,v1=230,v2=playlist[playingSong][3]})
	
	if resetDone then
		playSong()
		resetDone = false
	end

	if songChanged then
		resetSong()
		songChanged = false
		resetDone = true
	end
	
-- Song Over
	if model.getTimer(2).value >= playlist[playingSong][3] then 
		if not nextSongSwitchPressed then			
			model.setTimer(2,{value=0})				
			nextSongSwitchPressed = true
			nextScreenUpdate = true	
			songChanged = true
			screenUpdate = true
			if playingSong == #playlist then
				playingSong = 1	else
				playingSong = playingSong + 1
			end	else 
		nextSongSwitchPressed = false
		end	
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
				model.setTimer(2,{value=0})		
			else
				playingSong = playingSong + 1
				model.setTimer(2,{value=0})				
			end
		end
	else
		nextSongSwitchPressed = false
	end

	-- Previous song
	if getValue(prevSongSwitchId) > 0 then
		if not prevSongSwitchPressed then
			model.setTimer(2,{value=0})				
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

--Initiate
local function init()
model.setCustomFunction(31,{switch=pause,func = 17})
model.setCustomFunction(32,{switch=randomS,func=3,value=2,active=1}) 

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

--event controls
local function run(event)

	-- INPUT HANDLING --
	if (event == EVT_ROT_RIGHT or event == EVT_MINUS_FIRST or event == EVT_MINUS_RPT) then
		if selection == #playlist then
			selection = 1 else
			selection = selection + 1
				end

		screenUpdate = true
	elseif (event == EVT_ROT_LEFT or event == EVT_PLUS_FIRST or event == EVT_PLUS_RPT) then
		if selection == 1 then
			selection = #playlist else
			selection = selection - 1
		end

		screenUpdate = true
	elseif event == EVT_ROT_BREAK or event == EVT_ENTER_BREAK then -- Play selected song
		playingSong = selection
		songChanged = true
		screenUpdate = true
		model.setTimer(2,{value=0})	
	elseif nextScreenUpdate then
		selection = playingSong
		nextScreenUpdate = false
		model.setTimer(2,{value=0})
		end
		
	-- DRAWING --
	if screenUpdate or event == 191 then -- 191 is the event code when entering the telemetry screen
		screenUpdate = true

		lcd.clear();
		
		-- Calculate indexes for screen display
	if LCD_W == 212 then -- if Taranis X9D	
		local long=playlist[playingSong][3]
		local upTime=model.getTimer(2).value
		
		-- Title 9XD
		lcd.drawText(1, 1, "TaraniTunes", MIDSIZE)
		lcd.drawText(106, 1, "Played", SMLSIZE)
		lcd.drawTimer(110, 9, upTime, SMLSIZE)
		lcd.drawText(139, 1, string.char(62),SMLSIZE)
		lcd.drawText(145, 1, "Song", SMLSIZE)
		lcd.drawTimer(144, 9, long, SMLSIZE)
		lcd.drawText(LCD_W - 19, 1, "By", SMLSIZE)
		lcd.drawText(LCD_W - 27, 9, "GilDev", SMLSIZE)
			
	else -- Title if Taranis Q X7
		lcd.drawText(1, 1, "TaraniTunes", MIDSIZE)
		lcd.drawText(LCD_W - 19, 1, "By", SMLSIZE)
		lcd.drawText(LCD_W - 27, 9, "GilDev", SMLSIZE)
	end
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
		lcd.drawText(1, 18, string.char(62) .. playlist[playingSong][1],0)

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
