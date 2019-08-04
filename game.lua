
local composer = require( "composer" )

local scene = composer.newScene()

local physics = require( "physics" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Initialize variables
local json = require( "json" )

local currentBladePath = system.pathForFile( "current_blade.json", system.DocumentsDirectory )

local WIDTH, HEIGHT = display.contentWidth, display.contentHeight
local DEMON_DELAY = 500 --demon spawning delay, ms
local MISS_DELAY = 1000 --delay after miss, ms
local SKULL_CHANCE = 10 --chance to get a skull (1/SCULL_CHANCE)
local SCORE = 0
local SKULLS = 0
local HERO
local BLADE

local left_button
local right_button
local stripes

local is_hit

-------------------------------For loading equipped blade----------------------------------------
local CURRENT_BLADE = {}
local currentBladeImage = "blades/dr_blade.png"
local currentBladeSkullImage
-------------------------------------------------------------------------------------------------

local DEMON_TABLE = {}

local SPAWN_POINTS = {
	{
		x = 0,
		y = HEIGHT / 4,
		direction = -1
	},
	{
		x = 0,
		y = HEIGHT * 3 / 8,
		direction = -1
	},
	{
		x = 0,
		y = HEIGHT / 2,
		direction = -1
	},
	{
		x = 0,
		y = HEIGHT * 5 / 8,
		direction = -1
	},
	{
		x = 0,
		y = HEIGHT * 3 / 4,
		direction = -1
	},
	{
		x = WIDTH,
		y = HEIGHT / 4,
		direction = 1
	},
	{
		x = WIDTH,
		y = HEIGHT * 3 / 8,
		direction = 1
	},
	{
		x = WIDTH,
		y = HEIGHT / 2,
		direction = 1
	},
	{
		x = WIDTH,
		y = HEIGHT * 5 / 8,
		direction = 1
	},
	{
		x = WIDTH,
		y = HEIGHT * 3 / 4,
		direction = 1
	},
}


-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
local function loadCurrentBlade()
	local file = io.open( currentBladePath, "r" )
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        CURRENT_BLADE = json.decode( contents )
    end

    if ( CURRENT_BLADE == nil or CURRENT_BLADE.blade_image == nil) then
        CURRENT_BLADE = {
			blade_image = "blades/dr_blade.png",
			description = "Old base sword",
			skull_image = "dr_skull_coin.png",
			price = 100,
			is_bought = true,
			is_equiped = true,
		}
    end

    currentBladeImage = CURRENT_BLADE.blade_image
    currentBladeSkullImage = CURRENT_BLADE.skull_image
end

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

local function endGame()
	composer.setVariable( "finalScore", SCORE )
	composer.setVariable( "farmedSkulls", SKULLS )
    composer.gotoScene( "highscore", { time=800, effect="crossFade" } )
end

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
local function setButtonsAvailability(arg)
	left_button:setEnabled(arg)
	right_button:setEnabled(arg)
end

local function slowDemonTransition()
	for i = #DEMON_TABLE, 2, -1 do
		local tempDemon = DEMON_TABLE[i]
		transition.to(tempDemon, {time=3000, x=WIDTH/2, y=HEIGHT/2})
	end
end

local function skullEndedListener( obj )
	display.remove(obj)
end


local function randomizedSkullCoin(demon)
	rand = math.random(SKULL_CHANCE)
	if (rand == 1) then
		--Create skull sprite
		local skull_seq_data = {
			{name = "skull_coin", start = 1, count = 2, time = 300}
		}	
		local options =
		{
    		width = 16,
    		height = 16,
    		numFrames = 2
		}
		local skull_sheet = graphics.newImageSheet( currentBladeSkullImage, options)

		skull = display.newSprite( backGroup, skull_sheet, skull_seq_data)
		skull.x = demon.x
		skull.y = demon.y - 8
		skull:play()

		transition.to(skull, { time=500, alpha=0.6, x=demon.x, y=demon.y - 30, onComplete=skullEndedListener })

		--Increase scull coins
		SKULLS = SKULLS + 1
	end
	
end

local function demonKilledListener( event )
	if(event.phase == "ended") then
		display.remove(event.target)
	end
end

local function heroKilledListener( event )
	if(event.phase == "ended") then
		slowDemonTransition()
		BLADE:rotate(45)
		timer.performWithDelay( 300, endGame )
	end
end

local function killDemon(temp)
	table.remove(DEMON_TABLE, 1)
	randomizedSkullCoin(temp)

    transition.cancel(temp)
    temp.myName = "demon_killed"
    temp:setSequence( "killed" )
    temp:addEventListener("sprite", demonKilledListener)
	temp:play()

    --Increase score
    SCORE = SCORE + 1
    scoreText.text = SCORE
end

local function killHero()
	--Hero killed
    setButtonsAvailability(false)
    stripes:pause()

    HERO:setSequence( "killed" )
    HERO:addEventListener("sprite", heroKilledListener)
    HERO:play()
end

local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2


        if ( ( obj1.myName == "demon" and obj2.myName == "slash" ) or
             ( obj1.myName == "slash" and obj2.myName == "demon" ) )
        then
        	is_hit = true
 			--Remove demon
 			local temp
 			if obj1.myName == "demon" then
 				temp = obj1
            else
            	temp = obj2
            end

            killDemon(temp)

        end

        if ( ( obj1.myName == "demon" and obj2.myName == "hero" ) or
             ( obj1.myName == "hero" and obj2.myName == "demon" ) )
        then
        	
        	killHero()
            
        end

    end
    
end
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------
---------------------------------DEMON---------------------------------------
-----------------------------------------------------------------------------

local function createDemon()
	local options1 =
	{
	    width = 32,
	    height = 32,
	    numFrames = 2
	}
	local options2 =
	{
	    width = 32,
	    height = 32,
	    numFrames = 4
	}

	local demon_sheet = graphics.newImageSheet( "dr_demon.png", options1)
	local demon_killed_sheet = graphics.newImageSheet( "dr_demon_killed.png", options2)
	
	local demon_seq_data = {
		{name = "demon", start = 1, count = 2, time = 300, sheet = demon_sheet},
		{name = "killed", start = 1, count = 4, time = 300, sheet = demon_killed_sheet, loopCount = 1}
	}

	
	demon = display.newSprite(mainGroup, demon_sheet, demon_seq_data)

	--Add physics to demon
	physics.addBody( demon, { radius=14, isSensor=true } )
	demon.myName = "demon"

	--Set spawn point and start moving
	local spawnPoint = SPAWN_POINTS[math.random( #SPAWN_POINTS )]
	demon.x = spawnPoint.x
	demon.y = spawnPoint.y
	demon:scale(spawnPoint.direction, 1)
	demon:play()
	transition.to( demon, { time=1500, delay=20, x=WIDTH/2, y=HEIGHT/2 } )
	table.insert(DEMON_TABLE, demon)
end





-----------------------------------------------------------------------------
---------------------------------SLASH---------------------------------------
-----------------------------------------------------------------------------

local function slashDelay( event )
    setButtonsAvailability(true)
end


function slashEndedListener( event )
	if(event.phase == "ended") then
		display.remove(event.target)
		BLADE.isVisible = true
		if not is_hit then
			setButtonsAvailability(false)
			timer.performWithDelay(MISS_DELAY, slashDelay, 1)
		end
	end
end



function makeSlash(position, direction)
	BLADE.isVisible = false
	local slash_seq_data = {
		{name = "slash", start = 1, count = 5, time = 150, loopCount = 1}
	}

	local options =
	{
	    width = 32,
	    height = 32,
	    numFrames = 5
	}
	local slash_sheet = graphics.newImageSheet( "dr_slash.png", options)

	is_hit = false

	local slash = display.newSprite(mainGroup, slash_sheet, slash_seq_data)
	slash.x = display.contentCenterX + position
	slash.y = display.contentCenterY
	slash:addEventListener( "sprite", slashEndedListener )
	slash:scale(direction, 1)
	slash.myName = "slash"
	physics.addBody( slash, { radius=9, isSensor=true } )
	slash:play()
	
end



local function handleLeftButtonEvent( event )
 	if ( "began" == event.phase ) then
 		makeSlash(-20, -1)
 	end
end

local function handleRightButtonEvent( event )
 	if ( "began" == event.phase ) then
 		makeSlash(20, 1)
 	end
end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	loadCurrentBlade()

	backGroup = display.newGroup()
    sceneGroup:insert( backGroup )
 
    mainGroup = display.newGroup()
    sceneGroup:insert( mainGroup )
 
    uiGroup = display.newGroup()
    sceneGroup:insert( uiGroup )

    physics.start()
    physics.setGravity( 0, 0 )

    -------------------------Set background-----------------------------------------
    local background = display.newImageRect(backGroup, "dr_new_background.png",
		display.contentWidth, 227)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	-------------------------Stripes on the road------------------------------------
	local stripes_seq_data = {
		{name = "stripes", start = 1, count = 2, time = 300}
	}	
	local options =
	{
    	width = 4,
    	height = 192,
    	numFrames = 2
	}
	local stripes_sheet = graphics.newImageSheet( "dr_new_stripes.png", options)

	stripes = display.newSprite( backGroup, stripes_sheet, stripes_seq_data)
	stripes.x = display.contentCenterX - 2
	stripes.y = display.contentCenterY + 20
	stripes:play()

	------------------------Set hero------------------------------------------------
	local options1 =
	{
	    width = 32,
	    height = 32,
	    numFrames = 2
	}
	local options2 =
	{
	    width = 32,
	    height = 32,
	    numFrames = 4
	}

	local hero_sheet = graphics.newImageSheet( "dr_hero.png", options1)
	local hero_killed_sheet = graphics.newImageSheet( "dr_hero_killed.png", options2)

	local hero_seq_data = {
		{name = "run", start = 1, count = 2, time = 300, sheet = hero_sheet},
		{name = "killed", start = 1, count = 4, time = 300, sheet = hero_killed_sheet, loopCount = 1},
	}
	

	HERO = display.newSprite(mainGroup, hero_sheet, hero_seq_data)
	HERO.x = display.contentCenterX
	HERO.y = display.contentCenterY
	physics.addBody( HERO, { radius=16, isSensor=true } )
	HERO.myName = "hero"
	HERO:play()

	------------------------Set blade------------------------------------------------
	local blade_seq_data = {
	{name = "blade", start = 1, count = 2, time = 300}
	}

	local options =
	{
	    width = 24,
	    height = 24,
	    numFrames = 2
	}
	
	local blade_sheet = graphics.newImageSheet(currentBladeImage, options)

	BLADE = display.newSprite(mainGroup, blade_sheet, blade_seq_data)
	BLADE.x = display.contentCenterX - 20
	BLADE.y = display.contentCenterY + 10
	BLADE:rotate(225)
	BLADE:play()

	-----------------------Text score-------------------------------------------------
	scoreText = display.newText( uiGroup, SCORE, WIDTH-15, 9, native.systemFont, 13 )

	-----------------------Widget-----------------------------------------------------
	local widget = require( "widget" )
	-----------------------LeftButton-------------------------------------------------
	left_button = widget.newButton(
    	{
    		width = 64,
        	height = 227,
        	id = "left_button",
        	onEvent = handleLeftButtonEvent
    	}
	)
	left_button.x = display.contentCenterX - display.contentWidth / 4
	left_button.y = display.contentCenterY
	left_button.alpha = 0
	left_button.isHitTestable = true
	uiGroup:insert(left_button)
	-----------------------RightButton------------------------------------------------
	right_button = widget.newButton(
    	{
    		width = 64,
        	height = 227,
        	id = "right_button",
        	onEvent = handleRightButtonEvent
    	}
	)
	right_button.x = display.contentCenterX + display.contentWidth / 4
	right_button.y = display.contentCenterY
	right_button.alpha = 0
	right_button.isHitTestable = true
	uiGroup:insert(right_button)

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		---physics.start()
        Runtime:addEventListener( "collision", onCollision )
        gameLoopTimer = timer.performWithDelay( DEMON_DELAY, createDemon, 0 )

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        timer.cancel( gameLoopTimer )
        physics.pause()
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        Runtime:removeEventListener( "collision", onCollision )
        composer.removeScene( "game" )
    end

end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
