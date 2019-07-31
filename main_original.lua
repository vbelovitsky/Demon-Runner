-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- Seed the random number generator
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

math.randomseed( os.time() )
local gameLoopTimer
local scoreText


local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
local uiGroup = display.newGroup()



--background
local background = display.newImageRect(backGroup, "dr_background.png",
	display.contentWidth, display.contentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

stripes_seq_data = {
	{name = "stripes", start = 1, count = 2, time = 300}
}

local options =
{
    width = 4,
    height = 171,
    numFrames = 2
}
local stripes_sheet = graphics.newImageSheet( "dr_stripes.png", options)

stripes_sprite = display.newSprite( backGroup, stripes_sheet, stripes_seq_data)
stripes_sprite.x = display.contentCenterX
stripes_sprite.y = display.contentCenterY + 10

stripes_sprite:play()
---------------------------------------------------------------

--hero
function create_hero( )
	local seq_data = {
		{name = "run", start = 1, count = 2, time = 300}
	}

	local options =
	{
	    width = 32,
	    height = 32,
	    numFrames = 2
	}
	local sheet = graphics.newImageSheet( "dr_hero.png", options)

	local sprite = display.newSprite(mainGroup, sheet, seq_data)
	sprite.x = display.contentCenterX
	sprite.y = display.contentCenterY
	physics.addBody( sprite, { radius=16, isSensor=true } )
	sprite.myName = "hero"
	return sprite
end

hero_sprite =  create_hero()
hero_sprite:play()
---------------------------------------------------------------



--blade

function create_blade()
	local seq_data = {
	{name = "blade", start = 1, count = 2, time = 300}
	}

	local options =
	{
	    width = 24,
	    height = 24,
	    numFrames = 2
	}
	local sheet = graphics.newImageSheet(mainGroup, "dr_blade.png", options)

	local sprite = display.newSprite(sheet, seq_data)
	sprite.x = display.contentCenterX - 20
	sprite.y = display.contentCenterY + 10
	sprite:rotate(225)
	return sprite
end

blade_sprite = create_blade()
blade_sprite:play()


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
function slashEndedListener(event)
	if(event.phase == "ended") then
		display.remove(event.target)
		blade_sprite.isVisible = true
	end
end

function make_slash(position, direction)
	blade_sprite.isVisible = false
	local seq_data = {
		{name = "slash", start = 1, count = 2, time = 200, loopCount = 2}
	}

	local options =
	{
	    width = 32,
	    height = 32,
	    numFrames = 5
	}
	local sheet = graphics.newImageSheet(mainGroup, "dr_slash.png", options)

	local sprite = display.newSprite(sheet, seq_data)
	sprite.x = display.contentCenterX + position
	sprite.y = display.contentCenterY
	sprite:addEventListener( "sprite", slashEndedListener )
	sprite:scale(direction, 1)
	sprite:play()
	--display.remove(sprite)
end



-----------------------------------------------------------------------
------------------------------WIDGETS----------------------------------
-----------------------------------------------------------------------

local widget = require( "widget" )

-----------------------------------------------------------------------
-----------------------------LEFT_BUTTON-------------------------------
-----------------------------------------------------------------------
local function handleLeftButtonEvent( event )
 	
 	if ( "began" == event.phase ) then
 		make_slash(-20, -1)
 	end
end

local left_button = widget.newButton(
    {
    	width = 64,
        height = 192,
        id = "left_button",
        onEvent = handleLeftButtonEvent
    }
)

left_button.x = display.contentCenterX - display.contentWidth / 4
left_button.y = display.contentCenterY


-----------------------------------------------------------------------
----------------------------RIGHT_BUTTON-------------------------------
-----------------------------------------------------------------------

local function handleRightButtonEvent( event )
 	
 	if ( "began" == event.phase ) then
 		make_slash(20, 1)
 	end
end

local right_button = widget.newButton(
    {
    	width = 64,
        height = 192,
        id = "right_button",
        onEvent = handleRightButtonEvent
    }
)

right_button.x = display.contentCenterX + display.contentWidth / 4
right_button.y = display.contentCenterY
---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------



scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )


