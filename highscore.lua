local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Initialize variables
local WIDTH, HEIGHT = display.contentWidth, display.contentHeight

local json = require( "json" )
 
local scoresTable = {}
local skullsTable = {}

local scoresPath = system.pathForFile( "score.json", system.DocumentsDirectory )
local skullsPath = system.pathForFile( "skulls.json", system.DocumentsDirectory )



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

local function loadAndSaveSkulls()
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

    skullsTable[1] = skullsTable[1] + composer.getVariable( "farmedSkulls" )

    --Save
    local file = io.open( skullsPath, "w" )
 
    if file then
        file:write( json.encode( skullsTable ) )
        io.close( file )
    end

end






local function gotoGame()
    composer.gotoScene( "game", { time=400, effect="crossFade" } )
end

local function gotoMenu()
    composer.gotoScene( "menu", { time=200, effect="crossFade" } )
end





-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	loadAndSaveScores()
	loadAndSaveSkulls()

	local sceneGroup = self.view

	---------------Set background---------------------------------------------------
	local background = display.newImageRect( sceneGroup, "dr_background.png",
		display.contentWidth, display.contentHeight)
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
	stripes.y = display.contentCenterY + 11

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
	local skulls = display.newText(sceneGroup, composer.getVariable( "farmedSkulls" ), WIDTH/2, tempY + 65, native.systemFont, 13, "center" )

	---------------Get widget------------------------------------------------------------------------------------------
	local widget = require( "widget" )
	---------------Double button---------------------------------------------------------------------------------------
	local doubleButton = widget.newButton(
    	{
        	width = 46,
        	height = 28,
        	defaultFile = "dr_double_button.png",
    	}
	)
	doubleButton.x = WIDTH / 3 - 3
	doubleButton.y = HEIGHT * 4 / 5 - 3
	doubleButton:addEventListener( "tap", gotoMenu )
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