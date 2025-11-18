package ex7

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
	colorChannelsIndices[ColorChannel.TextureRed] = 2
	colorChannelsIndices[ColorChannel.TextureGreen] = 2
	colorChannelsIndices[ColorChannel.TextureBlue] = 2
	colorChannelsIndices[ColorChannel.TextureAlpha] = 2
	colorChannelsIndices[ColorChannel.BackgroundRed] = 2
	colorChannelsIndices[ColorChannel.BackgroundGreen] = 2
	colorChannelsIndices[ColorChannel.BackgroundBlue] = 2

	if !LoadTexture(app, "./assets/02-textures-and-extension-libraries/colors.png", &app.characterTexture) {
		success = false
		log.info("Failed to laod the character \"foo\" texture")
	}
	SetTextureBlending(app.characterTexture, {sdl.BlendMode.BLEND})

	app.characterPosX = f32(app.window.width - app.characterTexture.width) * 0.5
	app.characterPosY = f32(app.window.height - app.characterTexture.height) * 0.5
	return success
}

Loop :: proc(app: ^App) {
	event := new(sdl.Event)
	quit := false
	for quit == false {
		sdl.zerop(event)
		channelToUpdate: ColorChannel = ColorChannel.Unknown
		for sdl.PollEvent(event) == true {
			#partial switch event.type {
			case sdl.EventType.QUIT:
				quit = true
			case sdl.EventType.KEY_DOWN:
				switch event.key.key {
				case sdl.K_ESCAPE:
					sdl.Log("Quiting")
					quit = true
				case sdl.K_A:
					channelToUpdate = ColorChannel.TextureRed
				case sdl.K_S:
					channelToUpdate = ColorChannel.TextureGreen
				case sdl.K_D:
					channelToUpdate = ColorChannel.TextureBlue
				case sdl.K_F:
					channelToUpdate = ColorChannel.TextureAlpha
				case sdl.K_Q:
					channelToUpdate = ColorChannel.BackgroundRed
				case sdl.K_W:
					channelToUpdate = ColorChannel.BackgroundGreen
				case sdl.K_E:
					channelToUpdate = ColorChannel.BackgroundBlue
				}
			}
		}
		if channelToUpdate != ColorChannel.Unknown {
			sdl.Log("ColorChannel %d", channelToUpdate)
			colorChannelsIndices[channelToUpdate] = colorChannelsIndices[channelToUpdate] + sdl.Uint8(1)
			if colorChannelsIndices[channelToUpdate] >= ColorMagnitudeCount {
				colorChannelsIndices[channelToUpdate] = sdl.Uint8(0)
			}
			sdl.Log(
				"Texture - R:%d G:%d B:%d A:%d | Background - R:%d G:%d B:%d",
				colorMagnitudes[colorChannelsIndices[ColorChannel.TextureRed]],
				colorMagnitudes[colorChannelsIndices[ColorChannel.TextureGreen]],
				colorMagnitudes[colorChannelsIndices[ColorChannel.TextureBlue]],
				colorMagnitudes[colorChannelsIndices[ColorChannel.TextureAlpha]],
				colorMagnitudes[colorChannelsIndices[ColorChannel.BackgroundRed]],
				colorMagnitudes[colorChannelsIndices[ColorChannel.BackgroundGreen]],
				colorMagnitudes[colorChannelsIndices[ColorChannel.BackgroundBlue]],
			)
		}
		sdl.SetRenderDrawColor(
			app.window.renderer,
			colorMagnitudes[colorChannelsIndices[ColorChannel.BackgroundRed]],
			colorMagnitudes[colorChannelsIndices[ColorChannel.BackgroundGreen]],
			colorMagnitudes[colorChannelsIndices[ColorChannel.BackgroundBlue]],
			0xFF,
		)
		sdl.RenderClear(app.window.renderer)
		SetTextureColor(
			app.characterTexture,
			colorMagnitudes[colorChannelsIndices[ColorChannel.TextureRed]],
			colorMagnitudes[colorChannelsIndices[ColorChannel.TextureGreen]],
			colorMagnitudes[colorChannelsIndices[ColorChannel.TextureBlue]],
		)
		SetTextureAlpha(app.characterTexture, colorMagnitudes[colorChannelsIndices[ColorChannel.TextureAlpha]])
		RenderTexture(
			app.characterPosX,
			app.characterPosY,
			app.characterTexture,
			nil,
			app.window,
			0,
			sdl.FPoint{f32(app.characterTexture.width / 2), f32(app.characterTexture.height / 2)},
		)
		sdl.RenderPresent(app.window.renderer)
	}
}
Init :: proc() -> ^App {
	app := new(App)
	if !InitSDL() {
		log.panic("Failed to initialize SDL")
	}
	window, ok := GenerateWindow("SDL ex 7", 640, 480)
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

