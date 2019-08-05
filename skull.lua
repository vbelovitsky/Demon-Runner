local composer = require( "composer" )

local scene = composer.newScene()

local widget = require( "widget" )
local tableView
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local WIDTH, HEIGHT = display.contentWidth, display.contentHeight

local json = require( "json" )

local bladeTablePath = system.pathForFile( "blade_table.json", system.DocumentsDirectory )
local currentBladePath = system.pathForFile( "current_blade.json", system.DocumentsDirectory )
local skullsPath = system.pathForFile( "skulls.json", system.DocumentsDirectory )

local BASE_BLADE_TABLE = {
	{
		blade_image = "blades/dr_blade.png",
		description = "Old base sword",
		skull_image = "dr_skull_coin.png",
		price = 0,
		is_bought = true,
		is_equiped = true,
	},

	{
		blade_image = "blades/dr_blade_gold.png",
		description = "Old, but gold",
		skull_image = "dr_skull_coin.png",
		price = 100,
		is_bought = false,
		is_equiped = false,
	},

	{
		blade_image = "blades/dr_blade_sword.png",
		description = "Medieval sword",
		skull_image = "dr_skull_coin.png",
		price = 50,
		is_bought = false,
		is_equiped = false,
	},

	{
		blade_image = "blades/dr_blade_hook.png",
		description = "Hook for demons",
		skull_image = "dr_skull_coin.png",
		price = 50,
		is_bought = false,
		is_equiped = false,
	},

	{
		blade_image = "blades/dr_blade_mace.png",
		description = "Crushing mace",
		skull_image = "dr_skull_coin.png",
		price = 50,
		is_bought = false,
		is_equiped = false,
	},

	{
		blade_image = "blades/dr_blade_axe.png",
		description = "Ancient frost axe",
		skull_image = "dr_skull_coin.png",
		price = 150,
		is_bought = false,
		is_equiped = false,
	},

	{
		blade_image = "blades/dr_blade_flame.png",
		description = "Cursed flame sword",
		skull_image = "dr_skull_coin.png",
		price = 150,
		is_bought = false,
		is_equiped = false,
	},

	{
		blade_image = "blades/dr_blade_oblivion.png",
		description = "Blade of oblivion",
		skull_image = "dr_skull_coin.png",
		price = 250,
		is_bought = false,
		is_equiped = false,
	}

}

local BLADE_TABLE = {}
local CURRENT_BLADE = {}
local skullsTable = {}
local SKULLS_SUM = 0
local skullSumText

local EQUIPPED = "EQUIPPED"
local EQUIP = "EQUIP"
local ROWS_TABLE = {}


local function gotoMenu()
    composer.gotoScene( "menu", { time=200, effect="crossFade" } )
end


local function loadBladeData( )
	--Load
    local file = io.open( bladeTablePath, "r" )
 
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        BLADE_TABLE = json.decode( contents )
    end

    if ( BLADE_TABLE == nil or #BLADE_TABLE == 0 ) then
        BLADE_TABLE = BASE_BLADE_TABLE
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

    SKULLS_SUM = skullsTable[1]

end



local function saveBladeData()
	--Save
    local file = io.open( bladeTablePath, "w" )
 
    if file then
        file:write( json.encode( BLADE_TABLE ) )
        io.close( file )
    end
end


local function saveSkulls( )
	--Save
	skullsTable[1] = SKULLS_SUM

    local file = io.open( skullsPath, "w" )
 	
    if file then
        file:write( json.encode( skullsTable ) )
        io.close( file )
    end
end


local function saveCurrentBlade( )
	--Save
	for i = 1, #BLADE_TABLE do
		if(BLADE_TABLE[i].is_equiped == true) then
			CURRENT_BLADE = BLADE_TABLE[i]
			print(CURRENT_BLADE.blade_image)
		end
	end

    local file = io.open( currentBladePath, "w" )
 	
    if file then
        file:write( json.encode( CURRENT_BLADE ) )
        io.close( file )
    end
end





local function bladeSprite(link)
	local blade_seq_data = {
		{name = "blade", start = 1, count = 2, time = 300}
	}

	local options =
	{
	    width = 24,
	    height = 24,
	    numFrames = 2
	}
	local blade_sheet = graphics.newImageSheet(link, options)
	local blade = display.newSprite(blade_sheet, blade_seq_data)
	blade:rotate(-45)
	return blade
end


local function skullSprite(link)
	local skull_seq_data = {
			{name = "skull_coin", start = 1, count = 2, time = 2000}
	}

	local options =
	{
	    width = 16,
	    height = 16,
	    numFrames = 2
	}
	local skull_sheet = graphics.newImageSheet(link, options)
	local skull = display.newSprite(skull_sheet, skull_seq_data)
	
	return skull
end


local function insertText()
	for i = 1, #BLADE_TABLE do
		tableView:insertRow{
            rowHeight = 48,
            rowColor = { 0 },
            lineColor = { 0 },
            params = {}  -- Include custom data in the row
		}
	end
	-- body
end


local function buyBlade(row, blade, index )
	
	if(SKULLS_SUM >= blade.price) then
		SKULLS_SUM = SKULLS_SUM - blade.price
		BLADE_TABLE[index].is_bought = true
		blade.is_bought = true
		skullSumText.text = SKULLS_SUM
		row[6].text = EQUIP

		saveBladeData()
		saveSkulls()
		tableView:reloadData()
	end
end

local function equipBlade( row, blade, index )

	for i = 1, #BLADE_TABLE do
		if(BLADE_TABLE[i].is_equiped == true) then
			BLADE_TABLE[i].is_equiped = false

			ROWS_TABLE["row"..row.index][6].text = EQUIP --BAD
		end
	end

	BLADE_TABLE[index].is_equiped = true
	row[6].text = EQUIPPED

	saveBladeData()
	saveCurrentBlade()
	tableView:reloadData()
end


local function onRowTouch( event )

	local row = event.target
	local bladeData = BLADE_TABLE[row.index]

	if(event.phase == "tap" or event.phase == "release") then

		if (bladeData.is_bought == false)then
			--Try to buy
			buyBlade(row, bladeData, row.index)
		else
			if (bladeData.is_equiped == false) then
				--Equip blade
				equipBlade(row, bladeData, row.index)
			end
		end

	end

end


local function onRowRender( event )
 	
    local row = event.row 

    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth

    local bladeData  = BLADE_TABLE[row.index]
    local text_label = bladeData.price

    if (bladeData.is_bought == true) then
    	if (bladeData.is_equiped == false) then
    		text_label = EQUIP
    	else
    		text_label = EQUIPPED
    	end
   	end


	--------------------------Background-----------------------------------------------------------------
    local background = display.newImageRect( row, "dr_item_background.png", 128, 48)
    background.x = rowWidth / 2
    background.y = rowHeight / 2

    --------------------------Blade sprite---------------------------------------------------------------
    local bladeImage = bladeSprite(bladeData.blade_image)
    row:insert(bladeImage)
    bladeImage:play()
    bladeImage.anchorX = 0
    bladeImage.x = 7
    bladeImage.y = rowHeight * 0.51
 
 	--------------------------Blade description----------------------------------------------------------
    local bladeDescriptionText = display.newText( row, bladeData.description, 0, 0, nil, 9 )
    bladeDescriptionText:setFillColor( 1 )
    bladeDescriptionText.anchorX = 0
    bladeDescriptionText.x = 35
    bladeDescriptionText.y = rowHeight * 0.3

    --------------------------Blade label (price)--------------------------------------------------------
    local bladeLabelText = display.newText( row, text_label, 0, 0, nil, 10 )
    bladeLabelText:setFillColor( 1 )
    bladeLabelText.anchorX = 0
    bladeLabelText.x = 35
    bladeLabelText.y = rowHeight * 0.78
    row.label = bladeLabelText

    --------------------------Skull image----------------------------------------------------------------
    local skullImage = skullSprite(bladeData.skull_image)
    row:insert(skullImage)
    skullImage:play()
    skullImage.anchorX = 0
    skullImage.x = 96
    skullImage.y = rowHeight * 0.77


    ROWS_TABLE["row"..row.index] = row --BAD

end

local function backMenuButtonPress( event )
	gotoMenu()
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view

	local background = display.newImageRect( sceneGroup, "dr_store_background.png",
		display.contentWidth, display.contentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	-----------------------------------Load blade and skulls json data----------------------------------------------------
	loadBladeData()
	loadSkulls()


	local backMenuButton = widget.newButton(
    	{
        width = 38,
        height = 20,
        defaultFile = "dr_menu_button.png",
        onPress = backMenuButtonPress
    	}
	)
	sceneGroup:insert(backMenuButton)
	backMenuButton.x = 19
	backMenuButton.y = 10


	----------------------------------Skull sum----------------------------------------------------------------
	skullSumText = display.newText(sceneGroup, SKULLS_SUM, 0, 0, native.systemFont, 12)
	skullSumText.x = 100
	if SKULLS_SUM / 1000 > 0 then skullSumText.x = 95 end
	skullSumText.y = 10


	-----------------------------------Skull sprite------------------------------------------------------------
	local skullImage = skullSprite("dr_skull_coin.png")
    sceneGroup:insert(skullImage)
    skullImage:play()
    skullImage.x = 117
    skullImage.y = 10

	-----------------------------------TableView---------------------------------------------------------------
	tableView = widget.newTableView(
    	{
        x = WIDTH/2,
     	y = HEIGHT/2 + 18,
        height = HEIGHT - 10,
        width = WIDTH,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
        isBounceEnabled = false
    	}
	)
	sceneGroup:insert(tableView)
 	
	insertText()

	print(tableView:getNumRows())

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
		saveBladeData()
		saveSkulls()
		saveCurrentBlade()
		composer.removeScene( "skull" )
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