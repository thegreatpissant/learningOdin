package ex10

import fmt "core:fmt"
import log "core:log"
import mem "core:mem"
import strings "core:strings"
import sdl "vendor:sdl3"
import sdl_image "vendor:sdl3/image"
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
	buttons:         [dynamic]^Button,
	width:           f32,
	height:          f32,
	timer:           Timer,
}

Texture :: struct {
	texture: ^sdl.Texture,
	width:   i32,
	height:  i32,
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
ColorMagnitudeCount :: 3
colorMagnitudes := [ColorMagnitudeCount]sdl.Uint8{0x00, 0x7f, 0xff}
colorChannelsIndices := [ColorChannel.Total]sdl.Uint8{}

InitSDL :: proc() -> bool {
	success := true
	if !sdl.Init({sdl.InitFlag.VIDEO}) {
		success = false
		sdl.Log("Failed to initialize SDL: %s\n", sdl.GetError())
	}
	return success
}

HandleButtonEvent :: proc(button: ^Button, event: ^sdl.Event, position: ^Position) {
	//  check if the event falls within the button
	if position.x > button.posX &&
	   position.x < button.posX + button.width &&
	   position.y > button.posY &&
	   position.y < button.posY + button.height {
		if event.type == sdl.EventType.MOUSE_BUTTON_DOWN {
			button.state = ButtonState.MouseDown
		} else if event.type == sdl.EventType.MOUSE_BUTTON_UP {
			button.state = ButtonState.MouseUp
		} else {
			button.state = ButtonState.MouseOver
		}
	} else {
		button.state = ButtonState.MouseOut
	}

	//  Check if the event acts on the button
}
RenderButton :: proc(app: ^App, button: ^Button) {
	textureButtonHeight := f32(button.texture.height / i32(ButtonState.LENGTH))
	textureButtonWidth := f32(button.texture.width)
	renderRect: sdl.FRect
	renderRect.x = 0
	renderRect.y = f32(button.state) * textureButtonHeight
	renderRect.w = textureButtonWidth
	renderRect.h = textureButtonHeight
	destRect: sdl.FRect
	destRect.x = button.posX
	destRect.y = button.posY
	destRect.w = textureButtonWidth
	destRect.h = textureButtonHeight

	RenderTexture(button.posX, button.posY, button.texture, &renderRect, &destRect, app, 0, sdl.FPoint{0, 0})
}

GenerateWindow :: proc(title: string, width: i32, height: i32) -> (^Window, bool) {
	success := true
	window := new(Window)
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

LoadTexture :: proc(app: ^App, location: string, texture: ^^Texture) -> bool {
	if texture^ == nil {
		texture^ = new(Texture)
	}
	renderer := app.window.renderer
	DestroyTexture(texture^)
	filename := strings.clone_to_cstring(location)
	defer delete(filename)
	tempSurface := sdl_image.Load(filename)
	if tempSurface == nil {
		sdl.Log("Failed to load image file \"%s\" : %s\n", filename, sdl.GetError())
		return false
	}
	texture^.width = tempSurface.w
	texture^.height = tempSurface.h

	if !sdl.SetSurfaceColorKey(tempSurface, true, sdl.MapSurfaceRGB(tempSurface, 0x00, 0xFF, 0xFF)) {
		sdl.Log("Failed to set surface color key: %s", sdl.GetError())
		return false
	}
	texture^.texture = sdl.CreateTextureFromSurface(renderer, tempSurface)
	sdl.DestroySurface(tempSurface)

	if texture^.texture == nil {
		sdl.Log("Failed to create texture: %s\n", sdl.GetError())
	}

	return true
}

SetTextureColor :: proc(texture: ^Texture, r, g, b: sdl.Uint8) {
	sdl.SetTextureColorMod(texture.texture, r, g, b)
}
SetTextureAlpha :: proc(texture: ^Texture, alpha: sdl.Uint8) {
	sdl.SetTextureAlphaMod(texture.texture, alpha)
}
SetTextureBlending :: proc(texture: ^Texture, blendMode: sdl.BlendMode) {
	sdl.SetTextureBlendMode(texture.texture, blendMode)
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
	pDstRect: ^sdl.FRect,
	app: ^App,
	degrees: f64,
	center: sdl.FPoint,
	flipMode := sdl.FlipMode.NONE,
) {
	textureToScreenRatioWidth := f32(app.window.width) / app.width
	textureToScreenRatioHeight := f32(app.window.height) / app.height

	srcRect: sdl.FRect
	if pSrcRect == nil {
		srcRect.x = 0
		srcRect.y = 0
		srcRect.h = f32(texture.width)
		srcRect.w = f32(texture.height)
	} else {
		srcRect.x = pSrcRect.x
		srcRect.y = pSrcRect.y
		srcRect.h = pSrcRect.h
		srcRect.w = pSrcRect.w
	}

	dstRect: sdl.FRect
	if pDstRect == nil {
		dstRect.x = 0
		dstRect.y = 0
		dstRect.h = f32(texture.width)
		dstRect.w = f32(texture.height)
	} else {
		dstRect.x = pDstRect.x
		dstRect.y = pDstRect.y
		dstRect.h = pDstRect.h
		dstRect.w = pDstRect.w
	}

	dstRect.x *= textureToScreenRatioWidth
	dstRect.w *= textureToScreenRatioWidth
	dstRect.y *= textureToScreenRatioHeight
	dstRect.h *= textureToScreenRatioHeight

	sdl.RenderTextureRotated(app.window.renderer, texture.texture, &srcRect, &dstRect, degrees, center, flipMode)
}

Loop :: proc(app: ^App) {
	event: sdl.Event
	quit := false
	textTexture := StringTexture(app, "Hello World")
    buff : [100]u8
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
                    sdl.Log("Starting Timer")
                    app.timer.startTime = sdl.GetTicks()
                }
			}
		}
        if(app.timer.startTime != 0) {
            s:= fmt.bprint(buff[:],"Milliseconds since start time: %d", sdl.GetTicks() - app.timer.startTime)
            textTexture = StringTexture(app, s)
        }

		sdl.RenderClear(app.window.renderer)
		//  Render the buttons
		for button in app.buttons {
			RenderButton(app, button)
		}
		//  Render the text
		RenderTexture(
			0,
			0,
			textTexture,
			&sdl.FRect{0, 0, f32(textTexture.width), f32(textTexture.height)},
			&sdl.FRect {
				(app.width / 2) - f32(textTexture.width / 2),
				(app.width / 2) - f32(textTexture.height / 2),
				f32(textTexture.width),
				f32(textTexture.height),
			},
			app,
			0,
			sdl.FPoint{f32(textTexture.width / 2), f32(textTexture.height / 2)},
		)
		sdl.RenderPresent(app.window.renderer)
	}
}

CleanupMedia :: proc(app: ^App) {
	for i := 0; i < len(app.buttons); i += 1 {
		free(app.buttons[i])
	}
	delete(app.buttons)
	sdl_ttf.CloseFont(app.font)
	app.font = nil
}

Cleanup :: proc(app: ^App) {
	CleanupMedia(app)
	sdl.DestroyRenderer(app.window.renderer)
	app.window.renderer = nil
	sdl.DestroyWindow(app.window.window)
	free(app.window)
	free(app)
}

LoadMedia :: proc(app: ^App) -> bool {
	success := true
	app.backgroundColor = sdl.Color{0xff, 0xff, 0xff, 0xff}
	app.font = CreateFont("./assets/08-true-type-fonts/lazy.ttf", 28)
	if app.font == nil {
		log.panic("Failed to load font")
	}
	return success
}

Init :: proc() -> ^App {
	app := new(App)
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

