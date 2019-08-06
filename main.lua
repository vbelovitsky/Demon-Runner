local composer = require( "composer" )
 
-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )

--Initialize ads
local ad = require("ad")
ad.init(30)

timer.performWithDelay(1000,
	function()
		ad.applovin.load("interstitial")
		ad.applovin.load("rewardedVideo")
	end
)

-- Go to the menu screen
composer.gotoScene( "menu" )