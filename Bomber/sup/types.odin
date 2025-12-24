package sup

import "base:runtime"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

Position :: sdl.FPoint

Character :: struct {
	texture: ^Texture,
	pos:     Position,
	xDir:	f32,
	yDir:	f32,	
	xVel:    f32,
	yVel:	 f32,
	deltaTime: u64,
}

UpdateCharacterAnimation :: proc(character:^Character, deltaTime:u64) { 
	character.deltaTime += deltaTime
	nsPerSecond :u64= sdl.NS_PER_SECOND / u64(character.texture.frames)
	passedFrames :u64= character.deltaTime / nsPerSecond
	character.deltaTime -= passedFrames * nsPerSecond
	character.texture.frame = (character.texture.frame + i32(passedFrames)) % character.texture.frames
}

App :: struct {
	_context: runtime.Context,
	timer:    Timer,
	title:    cstring,
	window:   ^sdl.Window,
	renderer: ^sdl.Renderer,
	width:    i32,
	height:   i32,
	font:     ^sdl_ttf.Font,
	text:     ^Text,
	fps:      FPS,
	character:     Character,
}

