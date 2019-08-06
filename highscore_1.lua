local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize Ad Networks
local applovin


-- Initialize variables


local WIDTH, HEIGHT = display.contentWidth, display.contentHeight

local json = require( "json" )
 
local scoresTable = {}
local skullsTable = {}

local scoresPath = system.pathForFile( "score.json", system.DocumentsDirectory )
local skullsPath = system.pathForFile( "skulls.json", system.DocumentsDirectory )

local skulls
local doubleButton

local SKULLS_SUM
local SKULLS_START

local tap_count = 0

local function loadAndSaveScores()
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

    --Update record
    scoresTable[1] =  composer.getVariable( "finalScore" )
	if (scoresTable[1] > scoresTable[2]) then
		scoresTable[2] = scoresTable[1]
	end

    --Save
    local file = io.open( scoresPath, "w" )
 
    if file then
        file:write( json.encode( scoresTable ) )
        io.close( file )
    end

end

local function loadSkulls()
 	--Load
    local file = io.open( skullsPath, "r" )
 
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        skullsTable = json.decode( contents )
    end
 
    if ( skullsTable == nil or #skullsTable == 0 ) then
        skullsTable = { 0 }
    end
    SKULLS_START = skullsTable[1]
end


local function saveSkulls( )
	skullsTable[1] = SKULLS_START + SKULLS_SUM

    --Save
    local file = io.open( skullsPath, "w" )
 
    if file then
        file:write( json.encode( skullsTable ) )
        io.close( file )
    end
end


local function adListener( event )
 
    if ( event.phase == "init" ) then  -- Successful initialization
        print( event.isError )
		timer.performWithDelay(1000,
			function()
				applovin.load("rewardedVideo")
			end
		)
 
    --elseif ( event.phase == "loaded" ) then  -- The ad was successfully loaded
   --      if ( event.type == "interstitial") then applovin.show("interstitial") end
 		-- if ( event.type == "rewardedVideo") then applovin.show("rewardedVideo") end
   --  -- elseif ( event.phase == "failed" ) then  -- The ad failed to load
    --     print( event.type )
    --     print( event.isError )
    --     print( event.response )

   --  elseif (event.phase == "displayed") then
   --  		SKULLS_SUM = SKULLS_SUM * 2
			-- skulls.text = SKULLS_SUM
			-- doubleButton:setEnabled(false)
			-- saveSkulls()
			-- timer.pause()

	-- elseif (event.phase == "validationSucceeded") then
	-- 		SKULLS_SUM = SKULLS_SUM * 2
	-- 		skulls.text = SKULLS_SUM
	-- 		doubleButton:setEnabled(false)
	-- 		saveSkulls()
	-- 		timer.pause()
	elseif (event.phase == "hidden") then
			SKULLS_SUM = SKULLS_SUM * 2
			skulls.text = SKULLS_SUM
			doubleButton:setEnabled(false)
			saveSkulls()
			timer.pause()

	elseif( event.phase == "validationExceededQuota" or event.phase == "validationRejected" or event.phase == "validationFailed" or event.phase =="failed") then
			timer.pause()
			timer.performWithDelay(1000,
				function()
					applovin.load("interstitial")
				end
			)

    end
end


local function doubleSkullsAd()
	if (tap_count < 5 and SKULLS_SUM ~= 0) then
		if (applovin.isLoaded("rewardedVideo") == true) then
			applovin.show("rewardedVideo")
			doubleButton.y = doubleButton.y - 10
		elseif(applovin.isLoaded("interstitial") == true) then
			applovin.show("interstitial")
			doubleButton.y = doubleButton.y + 10
		end
	end
	tap_count = tap_count + 1
end



local function gotoMenu()
    composer.gotoScene( "menu", { time=200, effect="crossFade" } )
end




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	-----------------------------------------------Init ads-------------------------------------------------------
	applovin = require( "plugin.applovin" )
	applovin.init( adListener, { sdkKey="YOUR_SDK_KEY", testMode=true } )
	--------------------------------------------------------------------------------------------------------------

	loadAndSaveScores()
	loadSkulls()
	SKULLS_SUM = composer.getVariable( "farmedSkulls" )

	local sceneGroup = self.view

	---------------Set background---------------------------------------------------
	local background = display.newImageRect( sceneGroup, "dr_new_background.png",
		display.contentWidth, 227)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	---------------Set stripes for background-------------------------------------------------------------------------
	local options =
	{
    	width = 4,
    	height = 169,
    	numFrames = 2
	}
	local stripes_sheet = graphics.newImageSheet( "dr_stripes.png", options)
    local stripes = display.newImageRect(sceneGroup, stripes_sheet, 2, 4, 169)
	stripes.x = display.contentCenterX - 2
	stripes.y = display.contentCenterY + 30

	---------------Set card--------------------------------------------------------------------------------------------
	local card = display.newImageRect( sceneGroup, "dr_highscores_background.png",
		110, 150)
	card.x = display.contentCenterX - 1
	card.y = display.contentCenterY + 2

	local tempY =  HEIGHT/5
	local finalScoreText = display.newText(sceneGroup, "Demons killed:", WIDTH/2, tempY, native.systemFont, 13, "center" )
	local finalScore = display.newText(sceneGroup, scoresTable[1], WIDTH/2, tempY + 13, native.systemFont, 13, "center" )
	local recordText = display.newText(sceneGroup, "Record:", WIDTH/2, tempY + 26,   native.systemFont, 13, "center" )
	local record = display.newText(sceneGroup, scoresTable[2], WIDTH/2, tempY + 39, native.systemFont, 13, "center" )
	local skullsText = display.newText(sceneGroup, "Skulls collected:", WIDTH/2, tempY + 52,   native.systemFont, 13, "center" )
	skulls = display.newText(sceneGroup, SKULLS_SUM, WIDTH/2, tempY + 65, native.systemFont, 13, "center" )

	---------------Get widget------------------------------------------------------------------------------------------
	local widget = require( "widget" )
	---------------Double button---------------------------------------------------------------------------------------
	doubleButton = widget.newButton(
    	{
        	width = 46,
        	height = 28,
        	defaultFile = "dr_double_button.png",
        	onRelease = doubleSkullsAd
    	}
	)
	doubleButton.x = WIDTH / 3 - 3
	doubleButton.y = HEIGHT * 4 / 5 - 3
	sceneGroup:insert(doubleButton)
	---------------Menu button-----------------------------------------------------------------------------------------
	local menuButton = widget.newButton(
    	{
        	width = 46,
        	height = 28,
        	defaultFile = "dr_menu_button.png",
    	}
	)
	menuButton.x = WIDTH * 2 / 3 + 2
	menuButton.y = HEIGHT * 4 / 5 - 3
	menuButton:addEventListener( "tap", gotoMenu )
	sceneGroup:insert(menuButton)

end

-- timer.performWithDelay(1000,
-- 	function()
-- 		applovin.load("rewardedVideo")
-- 	end
-- 	)
-- timer.performWithDelay(1500,
-- 	function()
-- 		applovin.load("interstitial")
-- 	end
-- 	)


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
	
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		saveSkulls()
	elseif ( phase == "did" ) then
		composer.removeScene( "highscore" )
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