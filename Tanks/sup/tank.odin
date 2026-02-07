package sup

import sdl "vendor:sdl3"

CreateTexture :: proc(
	renderer: ^sdl.Renderer,
	width: i32,
	height: i32,
) -> ^sdl.Texture {
	return sdl.CreateTexture(
		renderer,
		sdl.PixelFormat.RGBA8888,
		sdl.TextureAccess.TARGET,
		width,
		height,
	)
}

CreateTankTexture :: proc(
	renderer: ^sdl.Renderer,
	scale: f32,
) -> ^sdl.Texture {
	texture: ^sdl.Texture = CreateTexture(
		renderer,
		i32(6 * scale),
		i32(4 * scale),
	)
	sdl.SetTextureBlendMode(texture, {sdl.BlendMode.BLEND})
	sdl.SetRenderTarget(renderer, texture)
	origBlendMode: sdl.BlendMode
	sdl.GetRenderDrawBlendMode(renderer, &origBlendMode)
	sdl.SetRenderDrawBlendMode(renderer, {sdl.BlendMode.BLEND})
	sdl.SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0x00)
	sdl.RenderClear(renderer)
	sdl.SetRenderDrawColor(renderer, 0x00, 0xff, 0x00, 0xff)

	centerPoint := sdl.FPoint{f32(texture.w) * 0.5, f32(texture.h) * 0.5}
	RenderTank(renderer, &centerPoint, scale)
	sdl.SetRenderDrawBlendMode(renderer, origBlendMode)
	sdl.SetRenderTarget(renderer, nil)
	return texture
}

RenderTank :: proc(
	renderer: ^sdl.Renderer,
	position: ^sdl.FPoint,
	scale: f32,
) {
	// Render the tank body
	// 6x4
	bodyWidth := 6 * scale
	bodyHeight := 4 * scale
	topLeft := sdl.FPoint {
		position.x - 0.5 * bodyWidth,
		position.y - .5 * bodyHeight,
	}

	body := sdl.FRect{topLeft.x, topLeft.y, bodyWidth, bodyHeight}
	sdl.RenderRect(renderer, &body)
	// back markers
	sdl.RenderLine(
		renderer,
		topLeft.x,
		topLeft.y + 1 * scale,
		topLeft.x + 1 * scale,
		topLeft.y + 1 * scale,
	)
	sdl.RenderLine(
		renderer,
		topLeft.x,
		topLeft.y + 3 * scale,
		topLeft.x + 1 * scale,
		topLeft.y + 3 * scale,
	)
	// front markers
	sdl.RenderLine(
		renderer,
		topLeft.x + 5 * scale,
		topLeft.y + 0.75 * scale,
		topLeft.x + 5 * scale,
		topLeft.y + 1 * scale,
	)
	sdl.RenderLine(
		renderer,
		topLeft.x + 5 * scale,
		topLeft.y + 1 * scale,
		topLeft.x + 6 * scale,
		topLeft.y + 1 * scale,
	)
	sdl.RenderLine(
		renderer,
		topLeft.x + 5 * scale,
		topLeft.y + 3 * scale,
		topLeft.x + 5 * scale,
		topLeft.y + 3.25 * scale,
	)
	sdl.RenderLine(
		renderer,
		topLeft.x + 5 * scale,
		topLeft.y + 3 * scale,
		topLeft.x + 6 * scale,
		topLeft.y + 3 * scale,
	)
}

CreateTurretTexture :: proc(
	renderer: ^sdl.Renderer,
	scale: f32,
) -> ^sdl.Texture {
	texture: ^sdl.Texture = CreateTexture(
		renderer,
		i32(6 * scale),
		i32(2 * scale),
	)
	sdl.SetTextureBlendMode(texture, {sdl.BlendMode.BLEND})
	sdl.SetRenderTarget(renderer, texture)
	origBlendMode: sdl.BlendMode
	sdl.GetRenderDrawBlendMode(renderer, &origBlendMode)
	//sdl.SetRenderDrawBlendMode(renderer, {sdl.BlendMode.BLEND})
	sdl.SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0x00)
	sdl.RenderClear(renderer)
	sdl.SetRenderDrawColor(renderer, 0x00, 0xff, 0x00, 0xff)

	turretCenterPoint := sdl.FPoint{1 * scale, 1 * scale}
	RenderTurret(renderer, &turretCenterPoint, scale)
	sdl.SetRenderTarget(renderer, nil)
	sdl.SetRenderDrawBlendMode(renderer, origBlendMode)
	return texture
}

RenderTurret :: proc(
	renderer: ^sdl.Renderer,
	position: ^sdl.FPoint,
	scale: f32,
) {
	bodyWidth := 2 * scale
	bodyHeight := 2 * scale
	topLeft := sdl.FPoint {
		position.x - bodyWidth * 0.5,
		position.y - bodyHeight * 0.5,
	}
	turret := sdl.FRect{topLeft.x, topLeft.y, bodyWidth, bodyHeight}
	cannonWidth := 4 * scale
	cannonHeight := 0.5 * scale
	cannon := sdl.FRect {
		topLeft.x + bodyWidth,
		topLeft.y + 0.75 * scale,
		cannonWidth,
		cannonHeight,
	}
	sdl.RenderRect(renderer, &turret)
	sdl.RenderRect(renderer, &cannon)
}
