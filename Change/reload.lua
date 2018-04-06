local fileToLoad="/SCRIPTS/TELEMETRY/choose.lua" --[[this is the name of my test file 
                if your planning to try it at this stage rename it to iTunes.lua --]]
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
  local set=getValue("ls")
  if set > 512 then 
  set1=1 else
  if set >= 0 then
  set1=2 else
  if set < 0 and set > -512 then
  set1=3 else
  set1=4
  end
  end
  end   
  
  if active then
    page.run(...)
    active= not (...==EVT_ENTER_BREAK)
  else
    lcd.clear()
    lcd.drawText( 34, 8, "!! New PlayList Request !!", BLINK)
    lcd.drawText( 15, 20, "Select Playlist Slider Position", 0)
    lcd.drawText( 50, 33, "Slider Position =" .. set1, 0)
    lcd.drawText( 40, 45,"Press ENTER to Activate",0)
    clearTable(page)
    active= (...==EVT_ENTER_BREAK)
    model.setTimer(2,{value=0})
    thisPage.init()
  end
  return not (...==EVT_MENU_BREAK)
    
end

return thisPage
