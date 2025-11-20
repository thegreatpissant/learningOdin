package ex8

import log "core:log"
import strings "core:strings"
import sdl "vendor:sdl3"
import sdl_image "vendor:sdl3/image"
import sdl_ttf "vendor:sdl3/ttf"

Window :: struct {
	window:   ^sdl.Window,
	renderer: ^sdl.Renderer,
	width:    i32,
	height:   i32,
}

App :: struct {
	window:          ^Window,
	font:            ^sdl_ttf.Font,
	textTexture:     ^Texture,
	backgroundColor: sdl.Color,
	textPosX:        f32,
	textPosY:        f32,
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
TextureFromText :: proc(app: ^App, text: string, color: sdl.Color, texture: ^^Texture) -> bool {
	if texture^ == nil {
		texture^ = new(Texture)
	}
    renderer := app.window.renderer
	DestroyTexture(texture^)

    textSurface : ^sdl.Surface = sdl_ttf.RenderText_Blended( app.font, strings.clone_to_cstring(text), 0, color)
    if textSurface == nil {
        sdl.Log("Unable to render text surface! sdl_ttf Error: %s\n", sdl.GetError())
        return false
    }
    texture^.width = textSurface.w
    texture^.height = textSurface.h

    texture^.texture = sdl.CreateTextureFromSurface(renderer, textSurface)
    sdl.DestroySurface(textSurface)

    if texture^.texture == nil {
        sdl.Log("Failed to create texture from rendered text! sdl error: %s\n", sdl.GetError())
        return false
    }

	return true
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
	DestroyTexture(app.textTexture)

    sdl_ttf.CloseFont(app.font)
    app.font = nil

	sdl.DestroyRenderer(app.window.renderer)
	app.window.renderer = nil
	sdl.DestroyWindow(app.window.window)
	app.window.window = nil
	sdl_ttf.Quit()
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

	fontPath := "./assets/08-true-type-fonts/lazy.ttf"
	app.font = sdl_ttf.OpenFont(strings.clone_to_cstring(fontPath), 28)
	if app.font == nil {
		success = false
		sdl.Log("Failed to create sdl font %s", sdl.GetError())
	} else if !TextureFromText(app, "One at a time", sdl.Color{0xff, 0x00, 0x00, 0xff}, &app.textTexture) {
		success = false
		log.info("Failed to create text \"foo\" texture")
	}
	SetTextureBlending(app.textTexture, {sdl.BlendMode.BLEND})

	app.textPosX = f32(app.window.width - app.textTexture.width) * 0.5
	app.textPosY = f32(app.window.height - app.textTexture.height) * 0.5
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
			app.textTexture,
			colorMagnitudes[colorChannelsIndices[ColorChannel.TextureRed]],
			colorMagnitudes[colorChannelsIndices[ColorChannel.TextureGreen]],
			colorMagnitudes[colorChannelsIndices[ColorChannel.TextureBlue]],
		)
		SetTextureAlpha(app.textTexture, colorMagnitudes[colorChannelsIndices[ColorChannel.TextureAlpha]])
		RenderTexture(
			app.textPosX,
			app.textPosY,
			app.textTexture,
			nil,
			app.window,
			0,
			sdl.FPoint{f32(app.textTexture.width / 2), f32(app.textTexture.height / 2)},
		)
		sdl.RenderPresent(app.window.renderer)
	}
}
Init :: proc() -> ^App {
	app := new(App)
	if !InitSDL() {
		log.panic("Failed to initialize SDL")
	}
	window, ok := GenerateWindow("SDL ex 8", 640, 480)
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
	app := Init()
	if !LoadMedia(app) {
		log.panic("Failed to load media")
	}
	Loop(app)
	Cleanup(app)
}

