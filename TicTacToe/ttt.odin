package TicTacToe

import "core:fmt"
import "core:log"
import "core:strings"
import scalfolding "scalfolding"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

// Each Cell
Cell :: enum {
	PLAYER_ONE,
	PLAYER_TWO,
	NONE,
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
        sdl.RenderClear(app.window.renderer)
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
main :: proc() {
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

    fmt.println("Loop")
    Loop(app)
    fmt.println("Deinit")
	//  Deinit
	sdl_ttf.CloseFont(app.font)
	sdl_ttf.Quit()
	sdl.Quit()
}

