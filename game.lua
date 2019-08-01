
local composer = require( "composer" )

local scene = composer.newScene()

local physics = require( "physics" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local WIDTH, HEIGHT = display.contentWidth, display.contentHeight
local DEAD = false
local SCORE = 0
local HERO
local BLADE

local left_button
local right_button

local SPAWN_POINTS = {
	{
		x = 0,
		y = HEIGHT / 4,
		direction = -1
	},
	{
		x = 0,
		y = HEIGHT / 2,
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
		y = HEIGHT / 2,
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

local function endGame()
    composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

local function demonKilledListener( event )
	if(event.phase == "ended") then
		display.remove(event.target)
	end
end

local function heroKilledListener( event )
	if(event.phase == "ended") then
		display.remove(event.target)
		timer.performWithDelay( 300, endGame )
	end
end


local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2


        if ( ( obj1.myName == "demon" and obj2.myName == "slash" ) or
             ( obj1.myName == "slash" and obj2.myName == "demon" ) )
        then
 			--Remove demon
 			local temp
 			if obj1.myName == "demon" then
 				temp = obj1
            else
            	temp = obj2
            end

            transition.cancel(temp)
            temp:setSequence( "killed" )
            temp:addEventListener("sprite", demonKilledListener)
 			temp:play()

            --Increase score
            SCORE = SCORE + 1
            scoreText.text = "" .. SCORE
        end

        if ( ( obj1.myName == "demon" and obj2.myName == "hero" ) or
             ( obj1.myName == "hero" and obj2.myName == "demon" ) )
        then
        	
        	--Hero killed
        	left_button:setEnabled(false)
        	right_button:setEnabled(false)
        	BLADE:rotate(45)

        	HERO:setSequence( "killed" )
        	HERO:addEventListener("sprite", heroKilledListener)
        	HERO:play()
            
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
	physics.addBody( demon, { radius=16, isSensor=true } )
	demon.myName = "demon"

	--Set spawn point and start moving
	local spawnPoint = SPAWN_POINTS[math.random( #SPAWN_POINTS )]
	demon.x = spawnPoint.x
	demon.y = spawnPoint.y
	demon:scale(spawnPoint.direction, 1)
	demon:play()
	transition.to( demon, { time=1500, delay=20, x=WIDTH/2, y=HEIGHT/2 } )
end





-----------------------------------------------------------------------------
---------------------------------SLASH---------------------------------------
-----------------------------------------------------------------------------

function slashEndedListener( event )
	if(event.phase == "ended") then
		display.remove(event.target)
		BLADE.isVisible = true
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

	local slash = display.newSprite(mainGroup, slash_sheet, slash_seq_data)
	slash.x = display.contentCenterX + position
	slash.y = display.contentCenterY
	slash:addEventListener( "sprite", slashEndedListener )
	slash:scale(direction, 1)
	slash.myName = "slash"
	physics.addBody( slash, { radius=7, isSensor=true } )
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
	backGroup = display.newGroup()
    sceneGroup:insert( backGroup )
 
    mainGroup = display.newGroup()
    sceneGroup:insert( mainGroup )
 
    uiGroup = display.newGroup()
    sceneGroup:insert( uiGroup )

    physics.start()
    physics.setGravity( 0, 0 )

    -------------------------Set background-----------------------------------------
    local background = display.newImageRect(backGroup, "dr_background.png",
		display.contentWidth, display.contentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	-------------------------Stripes on the road------------------------------------
	local stripes_seq_data = {
		{name = "stripes", start = 1, count = 2, time = 300}
	}	
	local options =
	{
    	width = 4,
    	height = 169,
    	numFrames = 2
	}
	local stripes_sheet = graphics.newImageSheet( "dr_stripes.png", options)

	stripes = display.newSprite( backGroup, stripes_sheet, stripes_seq_data)
	stripes.x = display.contentCenterX - 2
	stripes.y = display.contentCenterY + 11
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
	local blade_sheet = graphics.newImageSheet("dr_blade.png", options)

	BLADE = display.newSprite(mainGroup, blade_sheet, blade_seq_data)
	BLADE.x = display.contentCenterX - 20
	BLADE.y = display.contentCenterY + 10
	BLADE:rotate(225)
	BLADE:play()

	-----------------------Text score-------------------------------------------------
	scoreText = display.newText( uiGroup, "" .. SCORE, WIDTH-10, 9, native.systemFont, 15 )

	-----------------------Widget-----------------------------------------------------
	local widget = require( "widget" )
	-----------------------LeftButton-------------------------------------------------
	left_button = widget.newButton(
    	{
    		width = 64,
        	height = 192,
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
        	height = 192,
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
        gameLoopTimer = timer.performWithDelay( 2000, createDemon, 0 )

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        timer.cancel( gameLoopTimer )
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        Runtime:removeEventListener( "collision", onCollision )
        physics.pause()
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
