
local composer = require( "composer" )

local scene = composer.newScene()

local physics = require( "physics" )

local widget = require( "widget" )

local gameLoopTimer

--ADS
local ad
local isConnected

--SOUNDS
local sound


-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local ATTEMPT = 0


-- Initialize variables
local json = require( "json" )

local currentBladePath = system.pathForFile( "current_blade.json", system.DocumentsDirectory )
local scoresPath = system.pathForFile( "score.json", system.DocumentsDirectory )
local RECORD = 0

local WIDTH, HEIGHT = display.contentWidth, display.contentHeight
local DEMON_DELAY = 420 --demon spawning delay, ms
local DEMON_SPEED = 1300 --demon speed to screen center
local MISS_DELAY = 1000 --delay after miss, ms
local SKULL_CHANCE = 8 --chance to get a skull (1/SCULL_CHANCE)
local SCORE = 0
local SKULLS = 0
local HERO
local BLADE

local left_button
local right_button
local stripes
local retry_button
local end_button
local retry_background
local loadingSprite

local is_hit
local is_killed = false

-------------------------------For loading equipped blade----------------------------------------
local CURRENT_BLADE = {}
local currentBladeImage = "blades/dr_blade.png"
local currentSlashImage = "slash/dr_slash.png"
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
local function loadScores()
 	--Load
    local file = io.open( scoresPath, "r" )
 
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        scoresTable = json.decode( contents )
    end
 
    if ( scoresTable == nil or #scoresTable == 0 ) then
        scoresTable = { 0, 0,}
    end

    RECORD = scoresTable[2]
end




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
			slash_image = "slash/dr_slash.png",
			description = "Old base sword",
			skull_image = "dr_skull_coin.png",
			price = 0,
			is_bought = true,
			is_equiped = true,
		}
    end

    currentBladeImage = CURRENT_BLADE.blade_image
    currentSlashImage = CURRENT_BLADE.slash_image
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

-- local function reviveHero()
-- 	is_killed = false
-- 	setButtonsAvailability(true)
-- 	stripes:play()
-- 	BLADE:rotate(-45)
-- 	HERO:setSequence("run")
-- 	HERO:play()
-- end

local function demonKilledListener( event )
	if(event.phase == "ended") then
		display.remove(event.target)
	end
end

local function slowDemonTransition()
	for i = #DEMON_TABLE, 2, -1 do
		local tempDemon = DEMON_TABLE[i]
		transition.to( tempDemon, { time=2500, delay=0, x=WIDTH/2, y=HEIGHT/2 } )
		timer.pause(gameLoopTimer)
	end
end

-- local function wipeAllDemons()
-- 	sound.play.splash()
-- 	for i = #DEMON_TABLE, 1, -1 do
-- 		local tempDemon = DEMON_TABLE[i]
-- 		if (tempDemon) then
-- 			tempDemon:setSequence( "killed" )
-- 			tempDemon:addEventListener("sprite", demonKilledListener)
-- 			tempDemon:play()
-- 		end
-- 	end
-- end

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
    		width = 80,
    		height = 80,
    		numFrames = 2
		}
		local skull_sheet = graphics.newImageSheet( currentBladeSkullImage, options)

		skull = display.newSprite( backGroup, skull_sheet, skull_seq_data)
		skull.x = demon.x
		skull.y = demon.y - 40
		skull:play()

		transition.to(skull, { time=500, alpha=0.6, x=demon.x, y=demon.y - 150, onComplete=skullEndedListener })

		--Increase scull coins
		SKULLS = SKULLS + 1
	end
	
end



-- function makeRetry()

-- 		local isLoadedInt = ad.applovin.isLoaded("interstitial")
-- 		local isLoadedRew = ad.applovin.isLoaded("rewardedVideo")

-- 		if (isLoadedRew == true) then
-- 			loadingSprite.alpha = 1
-- 			loadingSprite:play()
-- 			ad.applovin.show("rewardedVideo")
-- 		elseif (isLoadedInt == true) then
-- 			loadingSprite.alpha = 1
-- 			loadingSprite:play()
-- 			ad.applovin.show("interstitial")
-- 		else
-- 			loadingSprite.alpha = 1
-- 			loadingSprite:play()
-- 			ad.applovin.show("interstitial")
-- 		end
-- 		retry_background.alpha = 0
-- 		retry_button.alpha = 0
-- 		end_button.alpha = 0
-- 		loadingSprite.alpha = 0

-- 		timer.performWithDelay(1500,
-- 			function()
-- 				wipeAllDemons()
-- 				reviveHero()
-- 				timer.resume(gameLoopTimer)
-- 			end
-- 			)
-- end

-- local function handleRetryButtonEvent( event )
--  	makeRetry()
-- end

-- local function handleEndButtonEvent( event )
--  	endGame()
-- end

-- local function showRetry()
-- 	--Retry background
-- 	retry_background = display.newImageRect(retryGroup, "dr_retry_background.png",
-- 		330, 380)
-- 	retry_background.x = display.contentCenterX - 10
-- 	retry_background.y = display.contentCenterY

-- 	--Retry button
-- 	retry_button = widget.newButton(
--     	{
--     		width = 210,
--         	height = 140,
--         	id = "retry_button",
--         	onRelease = handleRetryButtonEvent,
--         	defaultFile = "dr_retry_button.png"
--     	}
-- 	)
-- 	retry_button.x = display.contentCenterX - 10
-- 	retry_button.y = display.contentCenterY - 85
-- 	retryGroup:insert(retry_button)

-- 	--EndGame button
-- 	end_button = widget.newButton(
--     	{
--     		width = 210,
--         	height = 140,
--         	id = "end_button",
--         	onPress = function()
--         		print("SUCCESS!!!!!!!!")
--         	end,
--         	onRelease = handleEndButtonEvent,
--         	defaultFile = "dr_endgame_button.png"
--     	}
-- 	)
-- 	end_button.x = display.contentCenterX - 10
-- 	end_button.y = display.contentCenterY + 85
-- 	retryGroup:insert(end_button)

-- end

local function heroKilledListener( event )
	if(event.phase == "ended") then
		HERO:removeEventListener("sprite", heroKilledListener)
		slowDemonTransition()
		timer.performWithDelay( 300, endGame ) --Comment to return retry
		-- local isLoadedInt = ad.applovin.isLoaded("interstitial")
		-- local isLoadedRew = ad.applovin.isLoaded("rewardedVideo")
		-- if (SCORE >= RECORD/2 and ATTEMPT == 0 and RECORD >= 10 and (isConnected == true or isLoadedInt == true or isLoadedRew == true)) then
		-- 	timer.performWithDelay(1000,
		-- 		function()
		-- 			showRetry()
		-- 		end)
		-- 	ATTEMPT = ATTEMPT + 1
		-- else
		-- 	timer.performWithDelay( 300, endGame )
		-- end
	end
end

local function killDemon(temp, slash)
	slash.one = true
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
	is_killed = true
	sound.play.death()
    setButtonsAvailability(false)
    stripes:pause()
    BLADE:rotate(45)

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
 			local slash
 			if obj1.myName == "demon" then
 				temp = obj1
 				slash = obj2
            else
            	temp = obj2
            	slash = obj1
            end

            if slash.one == false then
            	killDemon(temp, slash)
            end

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
	    width = 160,
	    height = 160,
	    numFrames = 2
	}
	local options2 =
	{
	    width = 160,
	    height = 160,
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
	physics.addBody( demon, { radius=70, isSensor=true } )
	demon.myName = "demon"

	--Set spawn point and start moving
	local spawnPoint = SPAWN_POINTS[math.random( #SPAWN_POINTS )]
	demon.x = spawnPoint.x
	demon.y = spawnPoint.y
	demon:scale(spawnPoint.direction, 1)
	demon:play()
	transition.to( demon, { time=DEMON_SPEED, delay=20, x=WIDTH/2, y=HEIGHT/2 } )
	table.insert(DEMON_TABLE, demon)
end





-----------------------------------------------------------------------------
---------------------------------SLASH---------------------------------------
-----------------------------------------------------------------------------

local function slashDelay( event )
	if (is_killed == false) then
   		setButtonsAvailability(true)
	end
end


function slashEndedListener( event )
	if(event.phase == "ended") then
		display.remove(event.target)
		BLADE.isVisible = true
		if not is_hit then
			sound.play.miss()
			setButtonsAvailability(false)
			timer.performWithDelay(MISS_DELAY, slashDelay, 1)
		else
			sound.play.splash()
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
	    width = 160,
	    height = 160,
	    numFrames = 5
	}
	local slash_sheet = graphics.newImageSheet( currentSlashImage, options)

	is_hit = false

	local slash = display.newSprite(mainGroup, slash_sheet, slash_seq_data)
	slash.x = display.contentCenterX + position
	slash.y = display.contentCenterY
	slash:addEventListener( "sprite", slashEndedListener )
	slash:scale(direction, 1)
	slash.myName = "slash"
	physics.addBody( slash, { radius=45, isSensor=true } )
	slash:play()

	slash.one = false --To kill only one demon per slash
end



local function handleLeftButtonEvent( event )
 	if ( "began" == event.phase ) then
 		makeSlash(-100, -1)
 	end
end

local function handleRightButtonEvent( event )
 	if ( "began" == event.phase ) then
 		makeSlash(100, 1)
 	end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	sound = require("sound")

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	loadScores()
	loadCurrentBlade()

	isConnected = require("internet")

	ad = require("ad")
	ad.init()
	ad.applovin.load("interstitial")
	ad.applovin.load("rewardedVideo")


	backGroup = display.newGroup()
    sceneGroup:insert( backGroup )
 
    mainGroup = display.newGroup()
    sceneGroup:insert( mainGroup )
 
    uiGroup = display.newGroup()
    sceneGroup:insert( uiGroup )

    retryGroup = display.newGroup()
    sceneGroup:insert( retryGroup )

    physics.start()
    physics.setGravity( 0, 0 )

    -------------------------Set background-----------------------------------------
    local background = display.newImageRect(backGroup, "dr_new_background.png",
		display.contentWidth, 1135)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	-------------------------Sky demon----------------------------------------------
	local sky_demon_seq_data = {
			{name = "sky_demon", start = 1, count = 5, time = 500}
	}	
	local options =
	{
    	width = 50,
    	height = 40,
    	numFrames = 5
	}
	local sky_demon_sheet = graphics.newImageSheet( "dr_sky_demon.png", options)

	sky_demon = display.newSprite( backGroup, sky_demon_sheet, sky_demon_seq_data)
	sky_demon.x = 430
	sky_demon.y = 55
	sky_demon:play()

	-------------------------Stripes on the road------------------------------------
	local stripes_seq_data = {
		{name = "stripes", start = 1, count = 2, time = 300}
	}	
	local options =
	{
    	width = 20,
    	height = 960,
    	numFrames = 2
	}
	local stripes_sheet = graphics.newImageSheet( "dr_new_stripes.png", options)

	stripes = display.newSprite( backGroup, stripes_sheet, stripes_seq_data)
	stripes.x = display.contentCenterX - 10
	stripes.y = display.contentCenterY + 100
	stripes:play()

	------------------------Set hero------------------------------------------------
	local options1 =
	{
	    width = 160,
	    height = 160,
	    numFrames = 2
	}
	local options2 =
	{
	    width = 160,
	    height = 160,
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
	physics.addBody( HERO, { radius=75, isSensor=true } )
	HERO.myName = "hero"
	HERO:play()

	------------------------Set blade------------------------------------------------
	local blade_seq_data = {
	{name = "blade", start = 1, count = 2, time = 300}
	}

	local options =
	{
	    width = 120,
	    height = 120,
	    numFrames = 2
	}
	
	local blade_sheet = graphics.newImageSheet(currentBladeImage, options)

	BLADE = display.newSprite(mainGroup, blade_sheet, blade_seq_data)
	BLADE.x = display.contentCenterX - 100
	BLADE.y = display.contentCenterY + 50
	BLADE:rotate(225)
	BLADE:play()

	-----------------------Text score-------------------------------------------------
	scoreText = display.newText( uiGroup, SCORE, WIDTH-75, 45, native.systemFont, 65 )

	-----------------------LeftButton-------------------------------------------------
	left_button = widget.newButton(
    	{
    		width = 320,
        	height = 1135,
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
    		width = 320,
        	height = 1135,
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
	sound.dispose()

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
