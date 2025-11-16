package sdl3Image

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
	window:          ^Window,
	renderTexture:   ^Texture,
	defaultTexture:  ^Texture,
	upTexture:       ^Texture,
	downTexture:     ^Texture,
	leftTexture:     ^Texture,
	rightTexture:    ^Texture,
	backgroundColor: sdl.Color,
}

Texture :: struct {
	texture: ^sdl.Texture,
	width:   i32,
	height:  i32,
}

initSDL :: proc() -> bool {
	success := true
	if !sdl.Init({sdl.InitFlag.VIDEO}) {
		success = false
		sdl.Log("Failed to initialize SDL: %s\n", sdl.GetError())
	}
	return success
}

generateWindow :: proc(title: string, width: i32, height: i32) -> (^Window, bool) {
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

loadTexture :: proc(app: ^App, location: string, texture: ^^Texture) -> bool {
	renderer := app.window.renderer
	destroyTexture(texture^)
	filename := strings.clone_to_cstring(location)
	tempSurface := sdl_image.Load(filename)
	if tempSurface == nil {
		sdl.Log("Failed to load image file \"%s\" : %s\n", filename, sdl.GetError())
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

destroyTexture :: proc(texture: ^Texture) {
	sdl.DestroyTexture(texture.texture)
	texture.texture = nil
	texture.width = 0
	texture.height = 0
}

RenderTexture :: proc(posX: f32, posY: f32, texture: ^Texture, window: ^Window) {
	destinationRectangle := sdl.FRect{posX, posY, f32(texture.width), f32(texture.height)}
	sdl.RenderTexture(window.renderer, texture.texture, nil, &destinationRectangle)
}

close :: proc(app: ^App) {
	destroyTexture(app.defaultTexture)
	destroyTexture(app.upTexture)
	destroyTexture(app.downTexture)
	destroyTexture(app.leftTexture)
	destroyTexture(app.rightTexture)

	sdl.DestroyRenderer(app.window.renderer)
	app.window.renderer = nil
	sdl.DestroyWindow(app.window.window)
	app.window.window = nil
	sdl.Quit()
}

loadMedia :: proc(app: ^App) {
	app.defaultTexture = new(Texture)
	if !loadTexture(app, "./assets/02-textures-and-extension-libraries/loaded.png", &app.defaultTexture) {
		log.info("Failed to laod the default texture")
	}
	app.rightTexture = new(Texture)
	if !loadTexture(app, "./assets/02-textures-and-extension-libraries/right.png", &app.rightTexture) {
		log.info("Failed to laod the right texture")
	}
	app.leftTexture = new(Texture)
	if !loadTexture(app, "./assets/02-textures-and-extension-libraries/left.png", &app.leftTexture) {
		log.info("Failed to laod the left texture")
	}
	app.upTexture = new(Texture)
	if !loadTexture(app, "./assets/02-textures-and-extension-libraries/up.png", &app.upTexture) {
		log.info("Failed to laod the up texture")
	}
	app.downTexture = new(Texture)
	if !loadTexture(app, "./assets/02-textures-and-extension-libraries/down.png", &app.downTexture) {
		log.info("Failed to laod the down texture")
	}
	app.renderTexture = app.defaultTexture
}

main :: proc() {
	if !initSDL() {
		log.panic("Failed to initialize SDL")
	}
	app := App{}
	window, ok := generateWindow("SDL ex 4", 640, 480)
	if !ok {
		log.panic("Failed to generate window")
	}
	app.window = window
	loadMedia(&app)
	event := new(sdl.Event)
	quit := false
	for quit == false {
		sdl.zerop(event)
		for sdl.PollEvent(event) == true {
			app.backgroundColor = sdl.Color{0xff, 0xff, 0xff, 0xff}
			if event.type == sdl.EventType.QUIT {
				sdl.Log("Quiting application")
				quit = true
			} else if event.type == sdl.EventType.KEY_DOWN {
				if event.key.key == sdl.K_ESCAPE {
					sdl.Log("Quiting")
					quit = true
				} else if event.key.key == sdl.K_UP {
					app.renderTexture = app.upTexture
				} else if event.key.key == sdl.K_DOWN {
					app.renderTexture = app.downTexture
				} else if event.key.key == sdl.K_LEFT {
					app.renderTexture = app.leftTexture
				} else if event.key.key == sdl.K_RIGHT {
					app.renderTexture = app.rightTexture
				} else {
					app.renderTexture = app.defaultTexture
				}
			} else if false && event.type == sdl.EventType.KEY_UP {
				// Switch back to default texture when key is up.
				if event.key.key == sdl.K_UP ||
				   event.key.key == sdl.K_DOWN ||
				   event.key.key == sdl.K_RIGHT ||
				   event.key.key == sdl.K_LEFT {
					app.renderTexture = app.defaultTexture
				}
			}
			keyStates := sdl.GetKeyboardState(nil)
			if keyStates[sdl.Scancode.UP] {
				app.backgroundColor.r = 0xFF
				app.backgroundColor.g = 0x00
				app.backgroundColor.b = 0x00
			} else if keyStates[sdl.Scancode.DOWN] {
				app.backgroundColor.r = 0x00
				app.backgroundColor.g = 0xFF
				app.backgroundColor.b = 0x00
			} else if keyStates[sdl.Scancode.LEFT] {
				app.backgroundColor.r = 0xFF
				app.backgroundColor.g = 0xFF
				app.backgroundColor.b = 0x00
			} else if keyStates[sdl.Scancode.RIGHT] {
				app.backgroundColor.r = 0x00
				app.backgroundColor.g = 0x00
				app.backgroundColor.b = 0xFF
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
			f32((app.window.width - app.renderTexture.width)) * .5,
			f32((app.window.height - app.renderTexture.height)) * .5,
			app.renderTexture,
			app.window,
		)
		sdl.RenderPresent(app.window.renderer)
	}
	close(&app)
}

