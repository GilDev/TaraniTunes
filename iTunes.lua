--[[ 
 TaraniTunes
 Version 2.1
 http://github.com/GilDev/TaraniTunes
 By GilDev
 http://gildev.tk

See the seperate README file(s) for setting up the "main.lua" file and automated playlist creation

-----Playlist trigger/reset file----------
------------do not edit below this line--------------]]

local fileToLoad="/SCRIPTS/TELEMETRY/main.lua"
local active = true

local thisPage={}
local page={}

local function clearTable(t)
  if type(t)=="table" then
    for i,v in pairs(t) do
      if type(v) == "table" then
        clearTable(v)
      end
      t[i] = nil
    end
  end
  collectgarbage()
  return t 
end

thisPage.init=function(...)
  if active then
    page=dofile(fileToLoad)
    page.init(...)
  end
  return true
end

thisPage.background=function(...)
  if active then
    page.background(...)
  end
  return true
end

thisPage.run=function(...)
 local set=getValue("s2")
  if set > 512 then 
  set1=4 else
  if set >= 0 then
  set1=3 else
  if set < 0 and set > -512 then
  set1=2 else
  set1=1
  end
  end
  end   
  if active then
    page.run(...)
    active= not (...==EVT_MENU_BREAK)
  else
  	-- Calculate indexes for screen display
	if LCD_W == 212 then -- if Taranis X9D	
    lcd.clear()
    lcd.drawText( 40, 8, "!! New PlayList Request !!", BLINK)
    lcd.drawText( 60, 20, "Select Playlist", 0)
    lcd.drawText( 48, 33, "Swicth S2 Position = " .. set1, 0)
    lcd.drawText( 40, 45,"Press ENTER to Activate",0)
    clearTable(page)
    active= (...==EVT_ENTER_BREAK)
    model.setTimer(2,{value=0})
    thisPage.init() else
    -- Title if Taranis Q X7
    lcd.clear()
    lcd.drawText( 8, 8, "!New Playlist Request!", BLINK,SMLSIZE)
    lcd.drawText( 22, 20, "Select Playlist",SMLSIZE)
    lcd.drawText( 16, 30, "Switch S2 Position = " .. set1, SMLSIZE)
    lcd.drawText(10, 40,"Press ENTER to Activate",SMLSIZE)
    clearTable(page)
    active= (...==EVT_ROT_BREAK)
    model.setTimer(2,{value=0})
    thisPage.init() 
  end
  end
  
  return not (...==EVT_MENU_BREAK)
end    


return thisPage
