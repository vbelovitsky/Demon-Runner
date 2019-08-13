local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local ad
local sound


local function gotoGame()
    composer.gotoScene( "game", { time=400, effect="crossFade" } )
end
 
local function gotoStore()
    composer.gotoScene( "skull", { time=200, effect="crossFade" } )
end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()

function scene:create( event )

	sound = require("sound")
	sound.load()

	ad = require("ad")
	ad.applovin.load("interstitial")
	ad.applovin.load("rewardedVideo")

	local sceneGroup = self.view

	local background = display.newImageRect( sceneGroup, "dr_new_menu.png",
		display.contentWidth, 1135)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	--Sky demon
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

	local widget = require( "widget" )
	local storeButton = widget.newButton(
    	{
        	width = 370,
        	height = 155,
        	defaultFile = "dr_store.png",
    	}
	)
	storeButton.x = display.contentCenterX - 7
	storeButton.y = display.contentHeight /2 + 75
	storeButton:addEventListener( "tap", gotoStore )
	sceneGroup:insert(storeButton)

	local widget = require( "widget" )
	local playButton = widget.newButton(
    	{
        	width = 510,
        	height = 205,
        	defaultFile = "dr_play.png",
    	}
	)
	playButton.x = display.contentCenterX - 6
	playButton.y = display.contentCenterY + display.contentHeight/4
	playButton:addEventListener( "tap", gotoGame )
	sceneGroup:insert(playButton)
	
	-- Code here runs when the scene is first created but has not yet appeared on screen

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		sound.play.background()
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		composer.removeScene( "menu" )
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