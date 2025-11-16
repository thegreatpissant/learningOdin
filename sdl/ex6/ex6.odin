package ex6

import log "core:log"
import strings "core:strings"
import sdl "vendor:sdl3"
import sdl_image "vendor:sdl3/image"

Window :: struct {
	window:   ^sdl.Window,
	renderer: ^sdl.Renderer,
	width:    i32,
	height:   i32,
}

App :: struct {
	window:           ^Window,
	characterTexture: ^Texture,
	backgroundColor:  sdl.Color,
	characterPosX:    f32,
	characterPosY:    f32,
	flipMode:         sdl.FlipMode,
	degrees:          f64,
}

Texture :: struct {
	texture: ^sdl.Texture,
	width:   i32,
	height:  i32,
}

InitSDL :: proc() -> bool {
	success := true
	if !sdl.Init({sdl.InitFlag.VIDEO}) {
		success = false
		sdl.Log("Failed to initialize SDL: %s\n", sdl.GetError())
	}
	return success
}

GenerateWindow :: proc(title: string, width: i32, height: i32) -> (^Window, bool) {
	success := true
	window := new(Window)
	window.width = width
	window.height = height
	windowTitle := strings.clone_to_cstring(title)
	if !sdl.CreateWindowAndRenderer(windowTitle, width, height, {}, &window.window, &window.renderer) {
		success = false
		sdl.Log("Failed to create window: %s ", sdl.GetError())
	}
	return window, success
}

LoadTexture :: proc(app: ^App, location: string, texture: ^^Texture) -> bool {
	if texture^ == nil {
		texture^ = new(Texture)
	}
	renderer := app.window.renderer
	DestroyTexture(texture^)
	filename := strings.clone_to_cstring(location)
	tempSurface := sdl_image.Load(filename)
	if tempSurface == nil {
		sdl.Log("Failed to load image file \"%s\" : %s\n", filename, sdl.GetError())
		return false
	}
	if !sdl.SetSurfaceColorKey(tempSurface, true, sdl.MapSurfaceRGB(tempSurface, 0x00, 0xFF, 0xFF)) {
		sdl.Log("Failed to set surface color key: %s", sdl.GetError())
		return false
	}
	texture^.texture = sdl.CreateTextureFromSurface(renderer, tempSurface)
	if texture^.texture == nil {
		sdl.Log("Failed to create texture: %s\n", sdl.GetError())
	}

	texture^.width = tempSurface.w
	texture^.height = tempSurface.h

	sdl.DestroySurface(tempSurface)

	return true
}

DestroyTexture :: proc(texture: ^Texture) {
	sdl.DestroyTexture(texture.texture)
	texture.texture = nil
	texture.width = 0
	texture.height = 0
}

RenderTexture :: proc(
	posX: f32,
	posY: f32,
	texture: ^Texture,
	pSrcRect: ^sdl.FRect,
	window: ^Window,
	degrees: f64,
	center: sdl.FPoint,
	flipMode := sdl.FlipMode.NONE,
) {
	srcRect: ^sdl.FRect
	if pSrcRect == nil {
		srcRect = &sdl.FRect{x = 0, y = 0, w = f32(texture.width), h = f32(texture.height)}
	} else {
		srcRect = pSrcRect
	}
	destinationRectangle := sdl.FRect{posX, posY, f32(texture.width), f32(texture.height)}
	sdl.RenderTextureRotated(
		window.renderer,
		texture.texture,
		srcRect,
		&destinationRectangle,
		degrees,
		center,
		flipMode,
	)
}

Cleanup :: proc(app: ^App) {
	DestroyTexture(app.characterTexture)

	sdl.DestroyRenderer(app.window.renderer)
	app.window.renderer = nil
	sdl.DestroyWindow(app.window.window)
	app.window.window = nil
	sdl.Quit()
}

LoadMedia :: proc(app: ^App) -> bool {
	success := true
	app.backgroundColor = sdl.Color{0xff, 0xff, 0xff, 0xff}

	if !LoadTexture(app, "./images/02-textures-and-extension-libraries/arrow.png", &app.characterTexture) {
		success = false
		log.info("Failed to laod the character \"foo\" texture")
	}

	app.characterPosX = f32(app.window.width - app.characterTexture.width) * 0.5
	app.characterPosY = f32(app.window.height - app.characterTexture.height) * 0.5
	return success
}
Loop :: proc(app: ^App) {
	event := new(sdl.Event)
	quit := false
	for quit == false {
		sdl.zerop(event)
		for sdl.PollEvent(event) == true {
			if event.type == sdl.EventType.QUIT {
				sdl.Log("Quiting application")
				quit = true
			} else if event.type == sdl.EventType.KEY_DOWN {
				if event.key.key == sdl.K_ESCAPE {
					sdl.Log("Quiting")
					quit = true
				}
				if event.key.key == sdl.K_LEFT {
					app.degrees -= 36
				}
				if event.key.key == sdl.K_RIGHT {
					app.degrees += 36
				}
                if event.key.key == sdl.K_1 {
                    app.flipMode = sdl.FlipMode.HORIZONTAL
                }
                if event.key.key == sdl.K_2 {
                    app.flipMode = sdl.FlipMode.NONE
                }
                if event.key.key == sdl.K_3 {
                    app.flipMode = sdl.FlipMode.VERTICAL
                }
			}
		}
		sdl.SetRenderDrawColor(
			app.window.renderer,
			app.backgroundColor.r,
			app.backgroundColor.g,
			app.backgroundColor.b,
			0xFF,
		)
		sdl.RenderClear(app.window.renderer)

		RenderTexture(
			app.characterPosX,
			app.characterPosY,
			app.characterTexture,
			nil,
			app.window,
			app.degrees,
			sdl.FPoint{f32(app.characterTexture.width / 2), f32(app.characterTexture.height / 2)},
			app.flipMode,
		)
		sdl.RenderPresent(app.window.renderer)
	}
}
Init :: proc() -> ^App {
	app := new(App)
	if !InitSDL() {
		log.panic("Failed to initialize SDL")
	}
	window, ok := GenerateWindow("SDL ex 4", 640, 480)
	if !ok {
		log.panic("Failed to generate window")
	}
	app.window = window
	return app
}

main :: proc() {
	app := Init()
	if !LoadMedia(app) {
		log.panic("Failed to load media")
	}
	Loop(app)
	Cleanup(app)
}

