package ex10

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

