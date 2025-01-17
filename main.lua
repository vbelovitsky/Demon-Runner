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

-- audio.reserveChannels( 1 )
-- audio.reserveChannels( 2 )
-- audio.reserveChannels( 3 )
-- audio.setVolume( 0.35, { channel=1 } ) -- background music
-- audio.setVolume( 1, { channel=2 } ) -- death
-- audio.setVolume( 1, { channel=3 } ) -- miss
-- audio.setVolume( 1, { channel=4 } ) -- splash
-- audio.setVolume( 1, { channel=5 } ) -- splash

-- Go to the menu screen
composer.gotoScene( "menu" )