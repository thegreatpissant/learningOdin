package sup

import sdl "vendor:sdl3"
import "core:fmt"

AudioSource :: struct { 
	spec : ^sdl.AudioSpec,
	buf : [^]u8,
	len : u32,
	stream : ^sdl.AudioStream,
	playing : bool
}

LoadWavSource :: proc(audioDevice: sdl.AudioDeviceID, location:cstring) -> ^AudioSource { 
	source := new(AudioSource)
	source.spec = new(sdl.AudioSpec)
	if !sdl.LoadWAV(location, source.spec, &source.buf, &source.len) { 
		fmt.printfln("Failed to load sound: %s", sdl.GetError())
		return nil
	}
	source.stream = sdl.CreateAudioStream(source.spec, nil)
	if source.stream == nil { 
		fmt.printfln("Failed to create sound stream %s", sdl.GetError())
		return nil
	}
	
	if !sdl.BindAudioStream(audioDevice, source.stream) { 
		fmt.printfln("Failed to bind sound stream %s", sdl.GetError())
		return nil
	}	

	source.playing = false
	return source
}

PrimeAudioSource :: proc(source:^AudioSource) { 
	if !source.playing  { 
		return
	}
	if sdl.GetAudioStreamQueued(source.stream) < i32(source.len) { 
		sdl.PutAudioStreamData(source.stream, source.buf, i32(source.len))
	}
}

StopAudioSource :: proc(source: ^AudioSource) -> bool { 
	if !sdl.ClearAudioStream(source.stream) { 
		fmt.printfln("Failed to stop audio stream: %s", sdl.GetError())
		return false
	}
	source.playing = false
	return true
}

PauseWavSource :: proc(source: ^AudioSource, ) { 
	sdl.UnbindAudioStream(source.stream)
	source.playing = false
}

PlayWavSource :: proc(audioDevice: sdl.AudioDeviceID, source: ^AudioSource) { 
	if !sdl.BindAudioStream(audioDevice, source.stream) { 
		fmt.printfln("Failed to Bind audio stream: %s", sdl.GetError())
	}
	source.playing = true
}
