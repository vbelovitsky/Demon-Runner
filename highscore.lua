local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize Ad Networks
local ad
local isConnected


-- Initialize variables


local WIDTH, HEIGHT = display.contentWidth, display.contentHeight

local json = require( "json" )
 
local scoresTable = {}
local skullsTable = {}

local scoresPath = system.pathForFile( "score.json", system.DocumentsDirectory )
local skullsPath = system.pathForFile( "skulls.json", system.DocumentsDirectory )

local skulls
local doubleButton
local loadingSprite
local menuButton

local SKULLS_SUM
local SKULLS_START = 0

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

local function increaseSkulls()
	if (SKULLS_SUM < 5) then
		SKULLS_SUM = SKULLS_SUM + 5
	else
		SKULLS_SUM = SKULLS_SUM * 2
	end
	
	skulls.text = SKULLS_SUM
	doubleButton:setEnabled(false)
	doubleButton.alpha = 0
	loadingSprite.alpha = 0
	saveSkulls()
	menuButton:setEnabled(true)
	tap_count = 5
end


local function doubleSkullsAd()
	if (tap_count < 5 and isConnected == true) then
		if (ad.applovin.isLoaded("rewardedVideo") == true) then
			loadingSprite.alpha = 1
			loadingSprite:play()
			menuButton:setEnabled(false)
			ad.applovin.show("rewardedVideo")
			timer.performWithDelay(100,
				function( )
					increaseSkulls()
				end
				)
		elseif(ad.applovin.isLoaded("interstitial") == true) then
			loadingSprite.alpha = 1
			loadingSprite:play()
			menuButton:setEnabled(false)
			ad.applovin.show("interstitial")
			timer.performWithDelay(100,
				function( )
					increaseSkulls()
				end
				)
		else
			loadingSprite.alpha = 1
			loadingSprite:play()
			menuButton:setEnabled(false)
			ad.applovin.show("interstitial")
			timer.performWithDelay(100,
				function( )
					increaseSkulls()
				end
				)
			ad.applovin.load("rewardedVideo")
			ad.applovin.load("interstitial")
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

	isConnected = require("internet")

	ad = require("ad")
	ad.init()
	ad.applovin.load("interstitial")
	ad.applovin.load("rewardedVideo")


	
	--------------------------------------------------------------------------------------------------------------


	loadAndSaveScores()
	loadSkulls()
	SKULLS_SUM = composer.getVariable( "farmedSkulls" )

	local sceneGroup = self.view

	---------------Set background---------------------------------------------------
	local background = display.newImageRect( sceneGroup, "dr_new_background.png",
		display.contentWidth, 1135)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	---------------Sky demon--------------------------------------------------------
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

	sky_demon = display.newSprite( sceneGroup, sky_demon_sheet, sky_demon_seq_data)
	sky_demon.x = 430
	sky_demon.y = 55
	sky_demon:play()

	---------------Set stripes for background-------------------------------------------------------------------------
	local options =
	{
    	width = 20,
    	height = 960,
    	numFrames = 2
	}
	local stripes_sheet = graphics.newImageSheet( "dr_new_stripes.png", options)
    local stripes = display.newImageRect(sceneGroup, stripes_sheet, 2, 20, 960)
	stripes.x = display.contentCenterX - 10
	stripes.y = display.contentCenterY + 150

	---------------Set card--------------------------------------------------------------------------------------------
	local card = display.newImageRect( sceneGroup, "dr_highscores.png",
		550, 750)
	card.x = display.contentCenterX - 5
	card.y = display.contentCenterY + 10

	local tempY =  HEIGHT/4
	local finalScoreText = display.newText(sceneGroup, "Demons killed:", WIDTH/2, tempY, native.systemFont, 65, "center" )
	local finalScore = display.newText(sceneGroup, scoresTable[1], WIDTH/2, tempY + 65, native.systemFont, 65, "center" )
	local recordText = display.newText(sceneGroup, "Record:", WIDTH/2, tempY + 130,   native.systemFont, 65, "center" )
	local record = display.newText(sceneGroup, scoresTable[2], WIDTH/2, tempY + 195, native.systemFont, 65, "center" )
	local skullsText = display.newText(sceneGroup, "Skulls collected:", WIDTH/2, tempY + 260,   native.systemFont, 65, "center" )
	skulls = display.newText(sceneGroup, SKULLS_SUM, WIDTH/2, tempY + 325, native.systemFont, 65, "center" )

	---------------Get widget------------------------------------------------------------------------------------------
	local widget = require( "widget" )
	---------------Double button---------------------------------------------------------------------------------------
	local back_button_file
	if (SKULLS_SUM < 5) then
		back_button_file = "dr_getmore_button.png"
	else
		back_button_file = "dr_double_button.png"
	end
	doubleButton = widget.newButton(
    	{
        	width = 230,
        	height = 140,
        	defaultFile = back_button_file,
        	onRelease = doubleSkullsAd
    	}
	)
	doubleButton.x = WIDTH / 3 - 15
	doubleButton.y = HEIGHT * 4 / 5 - 75
	sceneGroup:insert(doubleButton)


	---------------Loading sprite--------------------------------------------------------------------------------------
	local loading_seq_data = {
		{name = "loading", start = 1, count = 6, time = 900}
	}	
	local options =
	{
    	width = 210,
    	height = 120,
    	numFrames = 6
	}
	local loading_sheet = graphics.newImageSheet( "dr_loading.png", options)

	loadingSprite = display.newSprite( sceneGroup, loading_sheet, loading_seq_data)
	loadingSprite.x = doubleButton.x
	loadingSprite.y = doubleButton.y
	loadingSprite.alpha = 0


	---------------Menu button-----------------------------------------------------------------------------------------
	menuButton = widget.newButton(
    	{
        	width = 230,
        	height = 140,
        	defaultFile = "dr_menu_button.png",
    	}
	)
	menuButton.x = WIDTH * 2 / 3 + 10
	menuButton.y = HEIGHT * 4 / 5 - 75
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
		randomAd = math.random(10)
		if (randomAd == 1) then
			local isLoadedInt = ad.applovin.isLoaded("interstitial")
			local isLoadedRew = ad.applovin.isLoaded("rewardedVideo")
			if (isLoadedRew == true) then
				ad.applovin.show("rewardedVideo")
				ad.applovin.load("rewardedVideo")
				ad.applovin.load("interstitial")
			elseif (isLoadedInt == true) then
				ad.applovin.show("interstitial")
				ad.applovin.load("rewardedVideo")
				ad.applovin.load("interstitial")
			else
				ad.applovin.show("interstitial")
				ad.applovin.load("rewardedVideo")
				ad.applovin.load("interstitial")
			end
		end
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