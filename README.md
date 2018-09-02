# advanced-turtle-api

ComputerCraft Advanced-Turtle-API (ATA)
@Copyright 2018 Tim Trense

ComputerCraft is a Minecraft mod from http://www.computercraft.info/
This API is designed to extend the Turtle-API by
 - home-relative positioning system
 - advanced movement functions
 - advanced inventory management functions
 - a callback system for fueling and inventory
 - a fueling system
 
A recent copy of the API is available at pastebin via 6Nuic8ty
 
USAGE:
1 copy the api to your turtles memory
  pastebin get 6Nuic8ty ata
2 in any turtle script, before using the turtle, just execute the lua file like:
  dofile("ata")
3 use turtle functions

EXAMPLE:
  
  1
  dofile("ata")
  function freeInventory()
    -- asuming there is a chest below home position
    local pos = turtle.getPosition()
    turtle.goHome()
    local i = 0
    while i < 16 do
      turtle.select(i+1)
      turtle.placeDown()
      i = i + 1
    end
    turtle.goToPosition(pos) -- resume working
  end
  function mine()
    turtle.digDown()
    while turtle.detectUp() do turtle.digUp() end
  end
  function ensureWayFree()
    while turtle.detect() do turtle.dig() end
  end
  turtle.onInventoryFull = freeInventory
  turtle.doInField(10, 20, {main=mine, beforeMovement=ensureWayFree, afterMovement=nil})
  
