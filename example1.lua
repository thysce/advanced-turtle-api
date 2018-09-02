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

