local sound = {}


function sound.load()
	audio.reserveChannels( 1 )
	audio.reserveChannels( 10 )
	audio.reserveChannels( 3 )
	audio.setVolume( 0.4, { channel=1 } ) -- background music
	audio.setVolume( 1, { channel=10 } ) -- death
	audio.setVolume( 1, { channel=3 } ) -- miss
	audio.setVolume( 1, { channel=4 } ) -- splash
	audio.setVolume( 1, { channel=5 } ) -- splash

	sound.background = audio.loadStream( "audio/dr_background.wav")
	sound.splash = audio.loadSound( "audio/dr_splash.mp3" )
    sound.miss = audio.loadSound( "audio/dr_miss.wav" )
    sound.death = audio.loadStream( "audio/dr_death.ogg" )
end

sound.play = {}

function sound.play.background()
	if sound.background then
		audio.play(sound.background, {channel = 1, loops = -1})
	end
end

function sound.play.death()
	if sound.death then
		audio.play(sound.death, {channel = 2})
	end
end

function sound.play.miss()
	if sound.miss then
		audio.play(sound.miss, {channel = 3})
	end
end


function sound.play.splash()
	if sound.splash then
		if audio.isChannelPlaying(4) == true then
			audio.play(sound.splash, {channel=5, duration=400})
		else
			audio.play(sound.splash, {channel=4, duration=400})
		end
	end
end

function sound.dispose()
	audio.dispose( sound.splash )
    audio.dispose( sound.miss )
    audio.dispose( sound.death )
end



return sound