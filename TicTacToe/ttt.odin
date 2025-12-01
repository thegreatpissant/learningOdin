package TicTacToe

import "core:fmt"
import "core:log"
import "core:strings"
import mem "core:mem"
import scalfolding "scalfolding"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

// Each Cell
Cell :: enum {
	PLAYER_X = 0,
	PLAYER_O,
	NONE,
}

Board :: struct {
	board : [3][3]Cell,
	texture : ^sdl.Texture
}

board : Board

RenderCell :: proc(renderer: ^sdl.Renderer, cell :^Cell, posx, posy, width, height :f32) {
	switch(cell^) {
	case .PLAYER_X :
		sdl.RenderLine(renderer, posx, posy, width, height)
		sdl.RenderLine(renderer, width, posy, posx, height)
		fallthrough
	case .PLAYER_O :
		for i in posx..<posx + width {
			for j in posy..<posy+height {
				if (i*i-posx) + (j*j-posy) < width * width {
					sdl.RenderPoint(renderer, posx+i, posy+j)
				}
			}
		}
	case .NONE :
		fmt.print('*')
	}
}

RenderBoard :: proc(app: ^scalfolding.App) {
	//  Render the background
	sdl.SetRenderTarget(app.window.renderer, board.texture)
	sdl.SetRenderDrawColor(app.window.renderer, 0x00, 0x00, 0x00, 0xff)
	sdl.RenderClear(app.window.renderer)
	vert := f32(app.width / 3)
	height := f32(app.height / 3)
	sdl.SetRenderDrawColor(app.window.renderer, 0xff, 0x00, 0x00, 0xff)
	if false {
	//  Vertical lines
	sdl.RenderLine(app.window.renderer,  vert, 0,  vert,  height * 3)
	sdl.RenderLine(app.window.renderer,  vert*2, 0,  vert*2,  height * 3)
	//  Horizontal lines
	sdl.RenderLine(app.window.renderer,  0,  height, vert * 3, height)
	sdl.RenderLine(app.window.renderer,  0,  height*2, vert * 3, height*2)
	}
	//  Render the cells
	for i in 0..<3 {
		for j in 0..<3 {
			posx :f32= f32(i) * height
			posy :f32= f32(j) * vert
			RenderCell(app.window.renderer, &board.board[i][j], posx, posy, vert, height)
		}
	}
	sdl.SetRenderTarget(app.window.renderer, nil)
}

Loop :: proc(app: ^scalfolding.App) {
	event: sdl.Event
	quit := false

	for quit == false {
		sdl.zerop(&event)
		for sdl.PollEvent(&event) == true {
			#partial switch event.type {
			case sdl.EventType.QUIT:
				quit = true
			case sdl.EventType.KEY_DOWN:
				switch event.key.key {
				case sdl.K_ESCAPE:
					quit = true
				}
			}
		}
		RenderBoard(app)
		sdl.RenderTexture(app.window.renderer, board.texture, nil, nil)
		sdl.RenderPresent(app.window.renderer)
	}
}
GenerateWindow :: proc(title: string, width: i32, height: i32) -> (^scalfolding.Window, bool) {
    success := true
    window := new(scalfolding.Window)
    window.width = width
    window.height = height
    windowTitle := strings.clone_to_cstring(title)
    defer delete(windowTitle)
    if !sdl.CreateWindowAndRenderer(windowTitle, width, height, {}, &window.window, &window.renderer) {
        success = false
        sdl.Log("Failed to create window: %s ", sdl.GetError())
    }
    return window, success
}

CreateTexture :: proc(app:^scalfolding.App, width, height :i32) -> ^sdl.Texture {
	return sdl.CreateTexture(app.window.renderer, sdl.PixelFormat.RGBA8888, sdl.TextureAccess.TARGET, width, height)
}

main :: proc() {
	//  Global Memory leak tracking
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	defer mem.tracking_allocator_destroy(&track)
	context.allocator = mem.tracking_allocator(&track)

	fmt.println("Running TicTacToe")
	app := new(scalfolding.App)
    app.height = 400
    app.width = 400
	//  Init
    fmt.println("Init SDL")
	if !sdl.Init({sdl.InitFlag.VIDEO}) {
		log.panicf("Failed to init SDL: %s", sdl.GetError())
	}
    fmt.println("Init SDL ttf")
    sdl_ttf.Init()
    fmt.println("Load Fonts")
	app.font = scalfolding.CreateFont("./assets/08-true-type-fonts/lazy.ttf", 28)
	if app.font == nil {
		log.panic("Failed to init SDL Font")
	}
    fmt.println("Create Window")
    window, ok := GenerateWindow("TicTacToe", app.width, app.height)
    if !ok {
        log.panic("Failed to create window")
    }
    app.window = window
	board.texture = CreateTexture(app, app.width, app.height)

    fmt.println("Loop")
    Loop(app)
    fmt.println("Deinit")
	//  Deinit
	sdl_ttf.CloseFont(app.font)
	sdl.DestroyTexture(board.texture)
	free(app.window)
	free(app)
	
	//  Close out sdl
	sdl_ttf.Quit()
	sdl.Quit()

	//  Leak detection list
	for _, leak in track.allocation_map {
		fmt.printf("%v leaked %m\n", leak.location, leak.size)
	}

}

