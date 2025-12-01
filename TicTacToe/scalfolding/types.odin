package scaffolding
import sdl "vendor:sdl3"
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
    width:           i32,
    height:          i32,
    text:            ^Text,
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