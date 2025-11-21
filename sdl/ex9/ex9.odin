package ex9

import log "core:log"
import strings "core:strings"
import sdl "vendor:sdl3"
import sdl_image "vendor:sdl3/image"

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

ButtonState :: enum i32 {
	MouseOut  = 0,
	MouseOver = 1,
	MouseDown = 2,
	MouseUp   = 3,
	LENGTH    = 4,
}

Button :: struct {
	texture: ^Texture,
	state:   ButtonState,
	width:   f32,
	height:  f32,
	posX:    f32,
	posY:    f32,
}

App :: struct {
	window:          ^Window,
	backgroundColor: sdl.Color,
	buttons:         [dynamic]^Button,
	buttonTexture:   ^Texture,
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

HandleButtonEvent :: proc(button: ^Button, event: ^sdl.Event) {
	//  check if the event falls within the button

	//  Check if the event acts on the button
}
RenderButton :: proc(app: ^App, button: ^Button) {
	textureButtonHeight := f32(button.texture.height / i32(ButtonState.LENGTH))
	textureButtonWidth := f32(button.texture.width)
    textureToScreenRatioWidth :f32= f32(app.window.width) / (textureButtonWidth*2)
    textureToScreenRatioHeight :f32= f32(app.window.height) / (textureButtonHeight*2)
	renderRect := new(sdl.FRect)
	renderRect.x = 0
	renderRect.y = f32(button.state) * textureButtonHeight
	renderRect.w = textureButtonWidth
	renderRect.h = textureButtonHeight
	destRect := new(sdl.FRect)
	destRect.x = button.posX * textureToScreenRatioWidth
	destRect.y = button.posY * textureToScreenRatioHeight
    destRect.w = textureButtonWidth * textureToScreenRatioWidth
    destRect.h = textureButtonHeight * textureToScreenRatioHeight

	RenderTexture(button.posX*textureToScreenRatioWidth, button.posY*textureToScreenRatioHeight, button.texture, renderRect, destRect, app.window, 0, sdl.FPoint{0, 0})
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

	dstRect: ^sdl.FRect
	if pDstRect == nil {
		dstRect = &sdl.FRect{x = 0, y = 0, w = f32(texture.width), h = f32(texture.height)}
	} else {
		dstRect = pDstRect
	}

	sdl.RenderTextureRotated(window.renderer, texture.texture, srcRect, dstRect, degrees, center, flipMode)
}

Cleanup :: proc(app: ^App) {
	sdl.DestroyRenderer(app.window.renderer)
	app.window.renderer = nil
	sdl.DestroyWindow(app.window.window)
	app.window.window = nil
	sdl.Quit()
}

Loop :: proc(app: ^App) {
	event := new(sdl.Event)
	quit := false
	for quit == false {
		sdl.zerop(event)
		for sdl.PollEvent(event) == true {
			#partial switch event.type {
			case sdl.EventType.QUIT:
				quit = true
			case sdl.EventType.KEY_DOWN:
				switch event.key.key {
				case sdl.K_ESCAPE:
					sdl.Log("Quiting")
					quit = true
				}
			}
		}

		sdl.RenderClear(app.window.renderer)
		//  Render the buttons
		for button in app.buttons {
			RenderButton(app, button)
		}
		sdl.RenderPresent(app.window.renderer)
	}
}

NewButton :: proc(app: ^App, texture: ^Texture, x: f32, y: f32) -> ^Button {
	button: ^Button = new(Button)
	button.posX = x
	button.posY = y
	button.state = ButtonState.MouseOut
    button.texture = texture
	return button
}
LoadMedia :: proc(app: ^App) -> bool {
	success := true
	app.backgroundColor = sdl.Color{0xff, 0xff, 0xff, 0xff}
	if !LoadTexture(app, "./assets/02-textures-and-extension-libraries/button.png", &app.buttonTexture) {
		success = false
		log.info("Failed to load button texture")
	}
    textureWidth := f32(app.buttonTexture.width)
    textureHeight := f32(app.buttonTexture.height / i32(ButtonState.LENGTH))

	cords := []Position{{0, 0}, {0, textureHeight}, {textureWidth, 0}, {textureWidth, textureHeight}}
	for position in cords {
		button := NewButton(app, app.buttonTexture, position.x, position.y)
		if button != nil {
			append(&app.buttons, button)
		}
	}
	return success
}

Init :: proc() -> ^App {
	app := new(App)
	if !InitSDL() {
		log.panic("Failed to initialize SDL")
	}
	window, ok := GenerateWindow("SDL ex 9", 640, 480)
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

