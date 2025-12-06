package scaffolding
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

Position :: struct {
    x: f32,
    y: f32,
}

Window :: struct {
    window:   ^sdl.Window,
    renderer: ^sdl.Renderer,
    width:    i32,
    height:   i32,
}

App :: struct {
    window:          ^Window,
    font:            ^sdl_ttf.Font,
    backgroundColor: sdl.Color,
    width:           i32,
    height:          i32,
	gameState:		 GameState,
	board: Board,
}

GameState :: enum { 
	Start = 0,
	Playing = 1,
	End = 2,
	UNKNOWN = 3,
}

// Each Cell
Cell :: enum {
	PLAYER_X = 0,
	PLAYER_O = 1,
	NONE,
}

Board :: struct {
	board : [3][3]Cell,
	texture : ^sdl.Texture
}


ColorChannel :: enum {
    TextureRed,
    TextureGreen,
    TextureBlue,
    TextureAlpha,
    BackgroundRed,
    BackgroundGreen,
    BackgroundBlue,
    Total,
    Unknown,
}
