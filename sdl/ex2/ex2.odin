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
	window: ^Window,
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

loadTexture :: proc(renderer: ^sdl.Renderer, location: string, texture: ^^Texture) -> bool {
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

renderTexture :: proc(posX: f32, posY: f32, texture: ^Texture, window: ^Window) {
	destinationRectangle := sdl.FRect{posX, posY, f32(window.width), f32(window.height)}
	sdl.RenderTexture(window.renderer, texture.texture, nil, &destinationRectangle)
}

close :: proc(app: ^App) {
    sdl.DestroyRenderer(app.window.renderer)
    app.window.renderer = nil
    sdl.DestroyWindow(app.window.window)
    app.window.window = nil
    sdl.Quit()
}

main :: proc() {
	if !initSDL() {
		log.panic("Failed to initialize SDL")
	}
	app := App{}
	window, ok := generateWindow("SDL ex 3", 700, 700)
	if !ok {
		log.panic("Failed to generate window")
	}
	app.window = window
	pngTexture := new(Texture)
	if !loadTexture(app.window.renderer, "./assets/02-textures-and-extension-libraries/loaded.png", &pngTexture) {
		log.info("Failed to laod the texture")
	}
	event := new(sdl.Event)
	quit := false
	for quit == false {
		sdl.zerop(event)
		for sdl.PollEvent(event) == true {
			if event.type == sdl.EventType.KEY_DOWN {
				if event.key.scancode == sdl.Scancode.ESCAPE {
					sdl.Log("Quiting")
					quit = true
				}
			}
		}
        sdl.SetRenderDrawColor(app.window.renderer, 0xFF, 0x00, 0xFF, 0xFF)
        sdl.RenderClear(app.window.renderer)
        renderTexture(0,0, pngTexture, app.window)
        sdl.RenderPresent(app.window.renderer)
	}
    destroyTexture(pngTexture)
	close(&app)
}

