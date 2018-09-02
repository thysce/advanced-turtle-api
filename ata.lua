-- ------------------------
-- ComputerCraft Advanced Turtle API
-- @Copyright 2018 Tim Trense
-- ------------------------
-- LICENCE
-- You are free to copy, redistribute and use this api for both commercial and free use.
-- You may modify this api in any form for your own use. Modificated versions of this api are not permitted to be redistributed.
-- To make public changes, you should perform a pull request.
-- ------------------------

turtleConstants = {}
turtleConstants.NORTH = 0
turtleConstants.EAST = 1
turtleConstants.SOUTH = 2
turtleConstants.WEST = 3
turtleConstants.RIGHT = 1
turtleConstants.LEFT = -1
turtleConstants.GOTO_XYZ = 0
turtleConstants.GOTO_XZY = 1
turtleConstants.GOTO_YXZ = 2
turtleConstants.GOTO_YZX = 3
turtleConstants.GOTO_ZXY = 4
turtleConstants.GOTO_ZYX = 5
turtleConstants.defaultGotoOrder = turtleConstants.GOTO_ZXY
turtleConstants.defaultFuelWarningLevel = 20
turtleConstants.defaultFuelRefuelLevel = 10
turtleConstants.defaultFuelRefuelAmount = 1

-- -------------------------- type definitions  --------------------------

-- slotNumber : int in interval from 1 to 16, boundaries included
-- position : object of x,y,z,dir:int with the home-relative coordinates and direction
-- gotoOrder : enum of turtleConstants.GOTO_XYZ, GOTO_XZY, .... until GOTO_ZYX
-- turnDirection : int eg. turtleConstants.LEFT * 2 or turtleConstants.RIGHT
-- direction : enum of turtleConstants.NORTH, EAST, SOUTH or WEST
-- movementActions : object of main,beforeMovement,afterMovement:function

-- -----------------------------------------------------

-- turtle is defined by ComputerCraft
-- some turtle functions will be replaced. those plain funtions are reachable under turtle.extend.DEPRECATED_FUNCTION

-- the turtles position and direction is meant to be relative to its home point and alignment
-- eg. if home is at (3,5,5) looking EAST then turtle coordinates (1,-2,0)/WEST is absolute at (4,3,5)/NORTH
turtle.x = 0 -- horizontal
turtle.y = 0 -- vertical
turtle.z = 0 -- height
turtle.dir = 0 -- one of turtleConstants.NORTH, EAST, SOUTH or WEST
turtle.fuelWarningEnabled = true -- decides, whether the onFuelWarning function will be called
turtle.fuelWarningLevel = turtleConstants.defaultFuelWarningLevel -- at that level and below the onFuelWarning function will be called
turtle.fuelRefuelLevel = turtleConstants.defaultFuelRefuelLevel -- at that level the turtle will try to refuel from its inventory
turtle.fuelRefuelAmount = turtleConstants.defaultFuelRefuelAmount -- by auto-refueling the turtle will take up to that amount of fuel inventory units
turtle.fuelAutoRefuel = true -- if false, the ensureFueled function will not be invoked before movements
turtle.acceptedFuel = {"minecraft:coal", "minecraft:lava"} -- array of names of items accepted as fuel
turtle.extend = {} -- object to hold the replaced old turtle functions

-- -------------------------- callback functions --------------------------
-- these functions are intended to be overridden by user

turtle.onFuelWarning = function(remaining)
	print("turtle: fuel warning: " .. remaining .. " remaining!")
	turtle.fuelWarningEnabled = false
end
turtle.onRefueled = function(remaining)
	print("turtle: refueled: " .. remaining .. " remaining!")
	turtle.fuelWarningEnabled = true
end
turtle.onOutOfFuel = function()
	print("turtle: out of fuel")
end
turtle.onInventoryFull = function()
	print("turtle: inventory full")
end

-- -------------------------- inventory functions --------------------------

-- @return int some inventory slot number with no items in it, -1 if no inventory slots are free
turtle.getFreeInventorySlot = function()
	local slot = 1
	while slot < 17 do
		if turtle.getItemDetail(slot) == nil then return slot end
		slot = slot + 1
	end
	return -1
end

-- @return boolean true if there is some free inventory slot, false otherwise
turtle.hasFreeInventorySlot = function()
	return turtle.getFreeInventorySlot() ~= -1
end

-- CAUTION: this does not mean, that all inventory item STACKS are full
-- @see turtle.hasFreeInventorySlot result is inverted
-- @return boolean true if there is no empty inventory slot anymore
turtle.isInventoryFull = function()
	return not turtle.hasFreeInventorySlot()
end

-- sums up all of the given items in the inventory
-- @param name string name of the item that shall be counted in the inventory
-- @return int amount of items of the given name in the inventory, 0 if none
turtle.countInInventory = function(name)
	local origSlot = turtle.getSelectedSlot()
	local slot = 1
	local sum = 0
	while slot <= 16 do
		local detail = turtle.getItemDetail(slot)
		if detail ~= nil and detail.name == name then sum = sum + detail.count end
		slot = slot + 1
	end
	return sum
end

-- sums up all items in the inventory being any of the given ones
-- @param names array of string all names of items to be counted
-- @return int sum of all amounts of the given items
turtle.countAnyInInventory = function(names)
	local sum = 0
	local i = 0
	while i < table.getn(names) do
		sum = sum + turtle.countInInventory(names[i+1])
		i = i + 1
	end
	return sum
end

-- @param name string name of the item to find
-- @return slotNumber slot number containing the given item, -1 if not found
turtle.findInInventory = function(name)
	local origSlot = turtle.getSelectedSlot()
	local slot = origSlot
	local allSearched = false
	while not allSearched do
		local detail = turtle.getItemDetail(slot)
		if detail ~= nil and detail.name == name then return slot end
		slot = slot + 1
		if slot > 16 then slot = 1 end
		if slot == origSlot then allSearched = true end
	end
	return -1  
end

-- selects the first slot in inventory containing the given item
-- @param name string name of the item to be found
-- @return slotNumber slot number that is selected now, -1 if selection did not change, because not found
turtle.selectInInventory = function(name)
  local slot = turtle.findInInventory(name)
  if slot > 0 and slot <= 16 then turtle.select(slot) end
  return slot
end

-- searches the inventory for a slot containing any of the given items, but does not select it
-- @see turtle.selectAnyInInventory
-- @param names array of string all names of items to be found
-- @return slotNumber first slot number containing any of the given items, -1 if non found
turtle.findAnyInInventory = function(names)
	local i = 0
	while i < table.getn(names) do
		local slot = turtle.findInInventory(names[i+1])
		if slot ~= -1 then return slot, i+1, names[i+1] end
		i = i + 1
	end
	return -1, 0, nil
end

-- selects the first slot in inventory containing any of the given items
-- @param names array of string all names of items to be found
-- @return slotNumber slot number that is selected now, -1 if selection did not change, because non found
turtle.selectAnyInInventory = function(names)
	local slot = turtle.findAnyInInventory(names)
	if slot > 0 and slot <= 16 then turtle.select(slot) end
	return slot
end

-- @param name string name of the item to be found
-- @return true if that item is in the inventory, false otherwise
turtle.hasInInventory = function(name)
	return turtle.findInInventory(name) ~= -1
end

-- @return slotNumber first slot number that contains any of the accepted items for fueling, -1 if no fuel is found in the inventory
turtle.findFuelInInventory = function()
	return turtle.findAnyInInventory(turtle.acceptedFuel)
end

-- @return boolean whether the inventory contains any fueling items anywhere
turtle.canRefuel = function()
	return turtle.findFuelInInventory() ~= -1
end

turtle.extend.refuel = turtle.refuel
-- @param amount int [optional, required if fuelSlot given, default = turtle.fuelRefuelAmount] how many items to be used to refuel
-- @param fuelSlot slotNumber [optional, default = any slot with fuel in it {@link turtle.findFuelInInventory}] the slot to pick the fuel from
-- @return int the fueling level after refuel
turtle.refuel = function(amount, fuelSlot)
	if fuelSlot == nil then fuelSlot = turtle.findFuelInInventory() end
	if fuelSlot < 1 or fuelSlot > 16 then return turtle.getFuelLevel() end
	local itemCount = turtle.getItemCount(fuelSlot)
	if amount == nil then amount = itemCount end
	
	if turtle.fuelRefuelAmount > 0 and turtle.fuelRefuelAmount < amount  then
		amount = turtle.fuelRefuelAmount
	end
	if amount > itemCount then amount = itemCount end
	
	local oldSlot = turtle.getSelectedSlot()
	turtle.select(fuelSlot)
	turtle.extend.refuel(amount)
	turtle.select(oldSlot)
	local fuelLevel = turtle.getFuelLevel()
	turtle.onRefueled(fuelLevel)
	return fuelLevel
end

-- called by the turtle itself before any action that may consume fuel, ONLY IF turtle.fuelAutoRefuel == true.
-- can be called by the used, for convenience.
-- tests whether the fueling level is below the fuel-warning-level and calls the onFuelWarning function if turtle.fuelWarningEnabled == true.
-- tests whether the fueling level is below the fuelRefuelLevel. if so, the turtle will try to refuel automatically.
-- if the turtle cannot refuel automatically (when the current fuel level is below the fuelRefuelLevel) then the onOutOfFuel function is called
-- @return boolean whether the fueling level is NOT zero and therefor allows at least one action
turtle.ensureFueled = function()
  local fuelLevel = turtle.getFuelLevel()
  if fuelLevel <= turtle.fuelWarningLevel and turtle.fuelWarningEnabled then
    turtle.onFuelWarning(fuelLevel)
	fuelLevel = turtle.getFuelLevel()
  end
  if fuelLevel <= turtle.fuelRefuelLevel then
    local slot = turtle.getSelectedSlot()
	local fuelSlot = turtle.findFuelInInventory()
	if fuelSlot == -1 then
	  turtle.onOutOfFuel()
	  return false
	end
    fuelLevel = turtle.refuel(turtle.fuelRefuelAmount, fuelSlot)
  end
  return fuelLevel > 0
end

-- -------------------------- inventory related action functions --------------------------

turtle.extend.dig = turtle.dig
turtle.dig = function()
	local r = turtle.extend.dig()
	if turtle.isInventoryFull() then turtle.onInventoryFull() end
	return r
end

turtle.extend.digDown = turtle.digDown
turtle.digDown = function()
	local r = turtle.extend.digDown()
	if turtle.isInventoryFull() then turtle.onInventoryFull() end
	return r
end

turtle.extend.digUp = turtle.digUp
turtle.digUp = function()
	local r = turtle.extend.digUp()
	if turtle.isInventoryFull() then turtle.onInventoryFull() end
	return r
end

turtle.extend.suck = turtle.suck
turtle.suck = function()
	local r = turtle.extend.suck()
	if turtle.isInventoryFull() then turtle.onInventoryFull() end
	return r
end

turtle.extend.suckDown = turtle.suckDown
turtle.suckDown = function()
	local r = turtle.extend.suckDown()
	if turtle.isInventoryFull() then turtle.onInventoryFull() end
	return r
end

turtle.extend.suckUp = turtle.suckUp
turtle.suckUp = function()
	local r = turtle.extend.suckUp()
	if turtle.isInventoryFull() then turtle.onInventoryFull() end
	return r
end

-- -------------------------- position and movement functions --------------------------

-- @return position the turtles current home-relative position
turtle.getPosition = function()
  return {x = turtle.x, y = turtle.y, z = turtle.z, dir = turtle.dir}
end

-- @return int the distance from home that must be travelled at minimum to reach home
turtle.getMinimumDistanceHome = function()
	return turtle.x + turtle.y + turtle.z
end

-- @param pos position the target position to go to (home-relative)
-- @param gotoOrder in which order to traverse
turtle.goToPosition = function(pos, gotoOrder)
  if pos == nil then return end
  turtle.goTo(pos.x, pos.y, pos.z, gotoOrder)
  turtle.turnTo(pos.dir)
end

turtle.extend.forward = turtle.forward
-- @param length int [optional, default 1] how many steps to go forward
-- @return int how many steps actually got forward
turtle.forward = function(length)
  if length == nil then length = 1 end
  if turtle.fuelAutoRefuel then turtle.ensureFueled() end
  local i = 0
  local actual = 0
  while i < length do
    if turtle.extend.forward() then
      if     turtle.dir == turtleConstants.NORTH then turtle.y = turtle.y + 1
      elseif turtle.dir == turtleConstants.EAST then turtle.x = turtle.x + 1
      elseif turtle.dir == turtleConstants.SOUTH then turtle.y = turtle.y - 1
      elseif turtle.dir == turtleConstants.WEST then turtle.x = turtle.x - 1
      end
	  actual = actual + 1
    end
    i = i + 1
  end
  return actual
end

turtle.extend.back = turtle.back
-- @param length int [optional, default 1] how many steps to go backwards
-- @return int how many steps actually got backwards
turtle.back = function(length)
  if length == nil then length = 1 end
  if turtle.fuelAutoRefuel then turtle.ensureFueled() end
  local i = 0
  local actual = 0
  while i < length do
    if turtle.extend.back() then
      if     turtle.dir == turtleConstants.NORTH then turtle.y = turtle.y - 1
      elseif turtle.dir == turtleConstants.EAST then turtle.x = turtle.x - 1
      elseif turtle.dir == turtleConstants.SOUTH then turtle.y = turtle.y + 1
      elseif turtle.dir == turtleConstants.WEST then turtle.x = turtle.x + 1
      end
	  actual = actual + 1
    end
    i = i + 1
  end
  return actual
end

turtle.extend.up = turtle.up
-- @param length int [optional, default 1] how many steps to go upwards
-- @return int how many steps actually got upwards
turtle.up = function(length)
  if length == nil then length = 1 end
  if turtle.fuelAutoRefuel then turtle.ensureFueled() end
  local i = 0
  local actual = 0
  while i < length do
    if turtle.extend.up() then
      turtle.z = turtle.z + 1
	  actual = actual + 1
    end
    i = i + 1
  end
  return actual
end

turtle.extend.down = turtle.down
-- @param length int [optional, default 1] how many steps to go downwards
-- @return int how many steps actually got downwards
turtle.down = function(length)
  if length == nil then length = 1 end
  if turtle.fuelAutoRefuel then turtle.ensureFueled() end
  local i = 0
  local actual = 0
  while i < length do
    if turtle.extend.down() then
      turtle.z = turtle.z - 1
	  actual = actual + 1
    end
    i = i + 1
  end
  return actual
end

turtle.extend.turnLeft = turtle.turnLeft
turtle.turnLeft = nil
turtle.extend.turnRight = turtle.turnRight
turtle.turnRight = nil
-- rotates the (looking direction of the) turtle
-- @param dir turnDirection relative direction
-- @return direction after-rotation-looking direction of the turtle
turtle.turn = function(dir)
  if dir == nil then dir = turtleConstants.RIGHT end
  local i = 0
  while i < math.abs(dir) do
    if dir < 0 then 
      turtle.extend.turnLeft()
      turtle.dir = turtle.dir - 1
    else
      turtle.extend.turnRight()
      turtle.dir = turtle.dir + 1
    end
	while turtle.dir < 0 do turtle.dir = turtle.dir + 4 end 
    while turtle.dir > 3 do turtle.dir = turtle.dir - 4 end
    i = i + 1
  end
  return turtle.dir
end

-- fast-forwards turtle.turn(turtleConstants.LEFT)
-- @param times int [optional, default 1] number how often to rotate left
-- @return direction after-rotation-looking direction of the turtle
turtle.turnLeft = function(times)
	if times == nil then times = 1 end
	local i = 0
	while i < times do
		turtle.turn(turtleConstants.LEFT)
		i = i + 1
	end
	return turtle.dir
end

-- fast-forwards turtle.turn(turtleConstants.RIGHT)
-- @param times int [optional, default 1] number how often to rotate right
-- @return direction after-rotation-looking direction of the turtle
turtle.turnRight = function(times)
	if times == nil then times = 1 end
	local i = 0
	while i < times do
		turtle.turn(turtleConstants.RIGHT)
		i = i + 1
	end
	return turtle.dir
end

-- turns 2 times so that the turtle inverts its current looking direction
-- @param dir turnDirection [optional, default LEFT] either turtleConstants.LEFT or turtleConstants.RIGHT
-- @return direction after-rotation-looking direction of the turtle
turtle.turnBackwards = function(dir)
	if dir == nil then dir = turtleConstants.LEFT end
	if dir == turtleConstants.RIGHT then
		turtle.turnRight(2)
	else
		turtle.turnLeft(2)
	end
	return turtle.dir
end

-- turns in a way such that the looking direction after this call is the given one
-- @param dir direction the target direction (home-relative)
turtle.turnTo = function(dir)
  if dir == turtle.dir then return end
  if dir > turtle.dir then
    turtle.turn(dir-turtle.dir)
  else
    turtle.turn(-(turtle.dir-dir))
  end
end

-- translates along the x axis (left/right)
-- @param x int target x coordinate (home-relative)
-- @param preserveDir boolean [optional, default true] whether to turn back to original direction
turtle.goToX = function(x, preserveDir)
	if x == nil then x = 0 end
	if preserveDir == nil then preserveDir = true end
	local dir = turtle.dir
	if turtle.x > x then
		turtle.turnTo(turtleConstants.WEST)
		turtle.forward(turtle.x - x)
	end
	if turtle.x < x then
		turtle.turnTo(turtleConstants.EAST)
		turtle.forward(x - turtle.x)
	end
	if preserveDir then turtle.turnTo(dir) end
end

-- translates along the y axis (fore/back)
-- @param y int target y coordinate (home-relative)
-- @param preserveDir boolean [optional, default true] whether to turn back to original direction
turtle.goToY = function(y, preserveDir)
	if y == nil then y = 0 end
	if preserveDir == nil then preserveDir = true end
	local dir = turtle.dir
	if turtle.y > y then
		turtle.turnTo(turtleConstants.SOUTH)
		turtle.forward(turtle.y - y)
	end
	if turtle.y < y then
		turtle.turnTo(turtleConstants.NORTH)
		turtle.forward(y - turtle.y)
	end
	if preserveDir then turtle.turnTo(dir) end
end

-- translates along the z axis (up/down)
-- @param z int target z coordinate (home-relative)
turtle.goToZ = function(z)
	if z == nil then z = 0 end
	if turtle.z < z then
		turtle.up(z - turtle.z)
	end
	if turtle.z > z then
		turtle.down(turtle.z - z)
	end
end

-- translates the turtle
-- @param dx int difference on the x axis
-- @param dy int difference on the y axis
-- @param dz int difference on the z axis
-- @param gotoOrder gotoOrder [optional, default see turtle.goTo]
turtle.go = function(dx, dy, dz, gotoOrder)
	if dx == nil then dx = 0 end
	if dy == nil then dy = 0 end
	if dz == nil then dz = 0 end
	dx = dx + turtle.x
	dy = dy + turtle.y
	dz = dz + turtle.z
	turtle.goTo(dx, dy, dz, gotoOrder)
end

-- translates the turtle to the given coordinates
-- @param x int x axis coordinate (home-relative)
-- @param y int y axis coordinate (home-relative)
-- @param z int z axis coordinate (home-relative)
-- @param gotoOrder gotoOrder [optional, default see turtleConstants.defaultGotoOrder]
turtle.goTo = function(x,y,z, gotoOrder)
	if gotoOrder == nil then gotoOrder = turtleConstants.defaultGotoOrder end
	local origdir = turtle.dir
	
	if gotoOrder == turtleConstants.GOTO_XYZ then 
		turtle.goToX(x)
		turtle.goToY(y)
		turtle.goToZ(z)
	elseif gotoOrder == turtleConstants.GOTO_XZY then
		turtle.goToX(x)
		turtle.goToZ(z)
		turtle.goToY(y)
	elseif gotoOrder == turtleConstants.GOTO_YXZ then
		turtle.goToY(y)
		turtle.goToX(x)
		turtle.goToZ(z)
	elseif gotoOrder == turtleConstants.GOTO_YZX then
		turtle.goToY(y)
		turtle.goToZ(z)
		turtle.goToX(x)
	elseif gotoOrder == turtleConstants.GOTO_ZXY then
		turtle.goToZ(z)
		turtle.goToX(x)
		turtle.goToY(y)
	elseif gotoOrder == turtleConstants.GOTO_ZYX then
		turtle.goToZ(z)
		turtle.goToY(y)
		turtle.goToX(x)
	end
	
	turtle.turnTo(origdir)
end

-- translates the turtle to (0,0,0)/NORTH home-relative
-- @param gotoOrder gotoOrder
turtle.goHome = function(gotoOrder)
  turtle.goTo(0,0,0, gotoOrder)
  turtle.turnTo(turtleConstants.NORTH)
end

-- sets the home-position and -direction of the turtle to the current one
turtle.home = function()
  turtle.x = 0
  turtle.y = 0
  turtle.z = 0
  turtle.dir = 0
end

-- moves the turtle one step forward with executing the given movementActions
-- @param actions movementActions the actions to perform before and after movement
-- @return boolean whether the one step forward succeeded
turtle.forwardWithActions = function(actions)
	if actions == nil then actions = {} end
	if actions.beforeMovement ~= nil then actions.beforeMovement() end
    local res = turtle.forward(1)
	if actions.afterMovement ~= nil then actions.afterMovement() end
	return res == 1
end

-- executes the given actions in a row, 
-- starting with the block the turtle currently stands on and length - 1 blocks in current looking direction
-- @param length int the distance of the line working on
-- @param actions movementActions main is executed once per block in the line
-- @return int the actual traversed length
turtle.doInLine = function(length, actions)
  local i = 0
  local actual = 0
  while i < length do
    actions.main()
	if turtle.forwardWithActions(actions) then actual = actual + 1 end
    i = i + 1
  end
  return actual
end

-- executes the given actions on a planar field,
-- starting with the block the turtle currently stands on and sizeY - 1 blocks in current looking direction 
-- and sizeX - 1 blocks to the turtles RIGHT
-- the starting point is on the lower left side of the field
-- @param sizeX int the dimension of the field to the turtles right
-- @param sizeY int the dimension of the field to the turtles front
-- @param actions movementActions main is executed once per block in the field
-- @return boolean whether the field was successfully traversed
turtle.doInField = function(sizeX, sizeY, actions)
  local i = 0
  local startPos = turtle.getPosition()
  local actual = 0
  local actualBack = 0
  if math.fmod(sizeX, 2) == 1 then
    actual = turtle.doInLine(sizeY-1, actions)
	actions.main()
	turtle.turnBackwards()
	actualBack = turtle.forward(actual)
	if actualBack ~= actual then 
		turtle.goToPosition(startPos)
		return false
	end
	turtle.turnBackwards()
    turtle.turn(turtleConstants.RIGHT)
	turtle.forwardWithActions(actions)
    turtle.turn(turtleConstants.LEFT)
    i = i + 1
  end
  while i < sizeX do
    actual = turtle.doInLine(sizeY-1, actions)
	actions.main()
    turtle.turnRight()
    turtle.forwardWithActions(actions)
    turtle.turnRight()
    actualBack = turtle.doInLine(actual, actions)
	if actualBack ~= actual then 
		turtle.goToPosition(startPos)
		return false
	end
	
    if i < sizeX - 2 then
		actions.main()
		turtle.turnLeft()
		turtle.forwardWithActions(actions)
		turtle.turnLeft()
    end
    i = i + 2
  end
  actions.main()
  turtle.goToPosition(startPos)
  return true
end

-- @see turtle.doInField fast-forward
turtle.doInSquare = function(size, action)
  turtle.doInField(size, size, action)
end

-- -------------------------- main-function of the turtle-api --------------------------

-- set home point to current position on initialization
turtle.home()