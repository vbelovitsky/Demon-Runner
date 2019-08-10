
local onAndroid = ( system.getInfo("platformName") == "Android")
local onDevice = onAndroid

local function genListener( eventName )
	local function listener( event )
		
		if ( not event.time ) then event.time = system.getTimer() end
		event.name = eventName
		Runtime:dispatchEvent(event)
	end
	return listener
end

local ad = {}
local listeners = {}

function ad.init( delay )
	
	local function initializeMonetizers()
		
		if (onAndroid) then
			local applovin = require("plugin.applovin")
			applovin.init(genListener("onAd_applovin"), {sdkKey = "gbwT9XOolS2cKyUy_aTBpX4xHdqWHDwytLSNtulDAJw3MV8ZS7eL-hD_2F5ci82CODBTtm1FBkgfhe60hlDT36"})
		end
	end

	if (not delay or delay < 1) then
		initializeMonetizers()
	else
		timer.performWithDelay(delay, initializeMonetizers)
	end

end


ad.applovin = {}

--Show helper
function ad.applovin.show( isIncentivized )
	local applovin = require("plugin.applovin")
	applovin.show(isIncentivized)
end

--Load helper
function ad.applovin.load( isIncentivized )
	local applovin = require("plugin.applovin")
	applovin.load(isIncentivized)
end

--Is helper loaded
function ad.applovin.isLoaded( isIncentivized )
	local applovin = require("plugin.applovin")
	applovin.isLoaded(isIncentivized)
end

return ad