package sup

import strings "core:strings"
import sdl "vendor:sdl3"
import sdl_image "vendor:sdl3/image"

Texture :: struct {
	texture: ^sdl.Texture,
	width:   i32,
	height:  i32,
	frames:  i32,
	frame:   i32,
	frameWidth : i32,
}

Animation :: struct {
	texture: ^Texture,
	frame: i32,
	pos:     Position,
	xDir:	f32,
	yDir:	f32,	
	xVel:    f32,
	yVel:	 f32,
	deltaTime: u64,
}

UpdateAnimation :: proc(animation:^Animation, deltaTime:u64) { 
	animation.deltaTime += deltaTime
	nsPerSecond :u64= sdl.NS_PER_SECOND / u64(animation.texture.frames)
	passedFrames :u64= animation.deltaTime / nsPerSecond
	animation.deltaTime -= passedFrames * nsPerSecond
	animation.frame = (animation.frame + i32(passedFrames)) % animation.texture.frames
}

GetSrcRectForAnimation :: proc(animation:^Animation) -> sdl.FRect { 
	width :f32= f32(animation.texture.width / animation.texture.frames)
	height :f32= f32(animation.texture.height)
	srcX :f32= width * f32(animation.frame)
	srcY :f32= 0
	return sdl.FRect{ srcX, srcY, width, height }
}
 
GetSrcRect :: proc(texture:^Texture) -> sdl.FRect { 
	width :f32= f32(texture.width / texture.frames)
	height :f32= f32(texture.height)
	srcX :f32= width * f32(texture.frame)
	srcY :f32= 0
	return sdl.FRect{ srcX, srcY, width, height }
}

LoadTexture :: proc(app: ^App, location: string, texture: ^^Texture, frameCount:i32 = 1) -> bool {
	if texture^ == nil {
		texture^ = new(Texture)
	}
	renderer := app.renderer
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

	if !sdl.SetSurfaceColorKey(tempSurface, true, sdl.MapSurfaceRGB(tempSurface, 0xff, 0x00, 0xFF)) {
		sdl.Log("Failed to set surface color key: %s", sdl.GetError())
		return false
	}
	texture^.texture = sdl.CreateTextureFromSurface(renderer, tempSurface)
	sdl.DestroySurface(tempSurface)

	if texture^.texture == nil {
		sdl.Log("Failed to create texture: %s\n", sdl.GetError())
	}

	texture^.frame = 0
	texture^.frames = frameCount
	texture^.frameWidth = texture^.width / frameCount

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
	texture: ^Texture,
	uSrcRect: sdl.FRect,
	uDstRect: sdl.FRect,
	app: ^App,
	degrees: f64,
	center: sdl.FPoint,
	flipMode := sdl.FlipMode.NONE,
) {
	textureToScreenRatioWidth := f32(app.width / app.width)
	textureToScreenRatioHeight := f32(app.height / app.height)

	srcRect: sdl.FRect
	srcRect.x = uSrcRect.x
	srcRect.y = uSrcRect.y
	srcRect.h = uSrcRect.h
	srcRect.w = uSrcRect.w

	dstRect: sdl.FRect
	dstRect.x = uDstRect.x
	dstRect.y = uDstRect.y
	dstRect.h = uDstRect.h
	dstRect.w = uDstRect.w

	dstRect.x *= textureToScreenRatioWidth
	dstRect.w *= textureToScreenRatioWidth
	dstRect.y *= textureToScreenRatioHeight
	dstRect.h *= textureToScreenRatioHeight

	sdl.RenderTextureRotated(app.renderer, texture.texture, &srcRect, &dstRect, degrees, center, flipMode)
}

