package ex10

import fmt "core:fmt"
import log "core:log"
import mem "core:mem"
import strings "core:strings"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"
import scal "scaffolding"

ColorMagnitudeCount :: 3
colorMagnitudes := [ColorMagnitudeCount]sdl.Uint8{0x00, 0x7f, 0xff}
colorChannelsIndices := [scal.ColorChannel.Total]sdl.Uint8{}

InitSDL :: proc() -> bool {
	success := true
	if !sdl.Init({sdl.InitFlag.VIDEO}) {
		success = false
		sdl.Log("Failed to initialize SDL: %s\n", sdl.GetError())
	}
	return success
}


GenerateWindow :: proc(title: string, width: i32, height: i32) -> (^scal.Window, bool) {
	success := true
	window := new(scal.Window)
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

Loop :: proc(app: ^scal.App) {
	event: sdl.Event
	quit := false

	buff: [100]u8
	for quit == false {
		sdl.zerop(&event)
		for sdl.PollEvent(&event) == true {
			#partial switch event.type {
			case sdl.EventType.QUIT:
				quit = true
			case sdl.EventType.KEY_DOWN:
				switch event.key.key {
				case sdl.K_ESCAPE:
					sdl.Log("Quiting")
					quit = true
				case sdl.K_RETURN:
					app.timer.startTime = sdl.GetTicks()
				}
			}
		}
		if (app.timer.startTime != 0) {
			app.text.text = fmt.bprintf(
				buff[:],
				"Milliseconds since start time: %d",
				sdl.GetTicks() - app.timer.startTime,
			)
			if !scal.UpdateText(app, app.text) {
				log.info("Failed to update text: %")
			}
		}

		sdl.RenderClear(app.window.renderer)

        //  Render the buttons
		for button in app.buttons {
            scal.RenderButton(app, button)
		}
		//  Render the text
        scal.RenderText(app, app.text)

		sdl.RenderPresent(app.window.renderer)
	}
}

CleanupMedia :: proc(app: ^scal.App) {
	for i := 0; i < len(app.buttons); i += 1 {
		free(app.buttons[i])
	}
	delete(app.buttons)
    scal.DestroyTexture(app.text.texture)
    free(app.text.texture)
    free(app.text)
	sdl_ttf.CloseFont(app.font)
	app.font = nil
}

Cleanup :: proc(app: ^scal.App) {
	CleanupMedia(app)
	sdl.DestroyRenderer(app.window.renderer)
	app.window.renderer = nil
	sdl.DestroyWindow(app.window.window)
	free(app.window)
	free(app)
}

LoadMedia :: proc(app: ^scal.App) -> bool {
	success := true
	app.backgroundColor = sdl.Color{0xff, 0xff, 0xff, 0xff}
	app.font = scal.CreateFont("./assets/08-true-type-fonts/lazy.ttf", 28)
	if app.font == nil {
		log.panic("Failed to load font")
	}
	app.text = new(scal.Text)
	app.text.text = "Hello World"
	app.text.color = sdl.Color{0xff, 0x00, 0x00, 0xff}
	app.text.font = app.font
    scal.UpdateText(app, app.text)
	app.text.position.x = app.width / 2
	app.text.position.y = app.height / 2
	return success
}

Init :: proc() -> ^scal.App {
	app := new(scal.App)
	app.width = 640
	app.height = 480

	if !InitSDL() {
		log.panic("Failed to initialize SDL")
	}
	window, ok := GenerateWindow("SDL ex 10", 640, 480)
	if !ok {
		log.panic("Failed to generate window")
	}
	app.window = window

	if !sdl_ttf.Init() {
		log.panic("Failed to initialize sdl_ttf, ", sdl.GetError())
	}

	return app
}

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	defer mem.tracking_allocator_destroy(&track)
	context.allocator = mem.tracking_allocator(&track)
	app := Init()
	if !LoadMedia(app) {
		log.panic("Failed to load media")
	}
	Loop(app)
	Cleanup(app)
	for _, leak in track.allocation_map {
		fmt.printf("%v leaked %m\n", leak.location, leak.size)
	}
	sdl_ttf.Quit()
	sdl.Quit()
}

