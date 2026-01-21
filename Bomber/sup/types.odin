package sup

import "core:mem"
import "base:runtime"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

Position :: sdl.FPoint


GameState :: enum { 
	RETRYSTART,
	START,
	RUN,
	PAUSE,
	LOSELEVEL,
	NEXTLEVEL,
	END,
	QUIT
}

App :: struct {
	allocator: runtime.Allocator,
	track: ^mem.Tracking_Allocator,
	_context: runtime.Context,
	timer:    Timer,
	title:    cstring,
	window:   ^sdl.Window,
	renderer: ^sdl.Renderer,
	width:    i32,
	height:   i32,
	font:     ^sdl_ttf.Font,
	fpsText:     ^Text,
	fps:      FPS,
	bomber: ^Bomber,
	player: ^Player,
	playerScoreText: ^Text,
	level:  int,
	bombs:  Bombs,
	buckets: ^Buckets,
	groundTexture: ^Texture,
	groundCollider: ^BoxCollider,
	gameState: GameState,
	bombBurstTimer: Timer,
	nextLevelTimer: Timer,
	bursting : bool,
}
