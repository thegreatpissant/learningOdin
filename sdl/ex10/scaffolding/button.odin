package scaffolding

import sdl "vendor:sdl3"

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

NewButton :: proc(app: ^App, texture: ^Texture, x: f32, y: f32) -> ^Button {
	button: ^Button = new(Button)
	button.posX = x
	button.posY = y
	button.width = f32(texture.width)
	button.height = f32(texture.height / i32(ButtonState.LENGTH))
	button.state = ButtonState.MouseOut
	button.texture = texture
	return button
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

	RenderTexture(button.texture, renderRect, destRect, app, 0, sdl.FPoint{0, 0})
}

