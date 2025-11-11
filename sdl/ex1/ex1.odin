package _main

import "core:log"
import "core:math/rand"
import sdl "vendor:sdl3"

WINDOW_WIDTH :: 1200
WINDOW_HEIGHT :: 760

renderRandomPoint :: proc( renderer:^sdl.Renderer)  {
    randX :f32= rand.float32() * WINDOW_WIDTH
    randY :f32= rand.float32() * WINDOW_WIDTH
    ok := sdl.RenderPoint(renderer, randX, randY )
    if !ok {
        log.panicf("Could not render point {}", sdl.GetError())
    }
}

_main :: proc() {
	context.logger = log.create_console_logger()

	ok := sdl.Init({.VIDEO})
	if !ok {
		log.panicf("Could not init SDL {}", sdl.GetError())
	}

	window := new(sdl.Window)
	renderer := new(sdl.Renderer)

	ok = sdl.CreateWindowAndRenderer("Hello SDL3", WINDOW_WIDTH, WINDOW_HEIGHT, {}, &window, &renderer)
	if !ok {
		log.panicf("Could not init SDL window {}", sdl.GetError())
	}

	main_loop: for {
		ev: sdl.Event
		for sdl.PollEvent(&ev) {
			#partial switch ev.type {
			case .QUIT:
				break main_loop
			case .KEY_DOWN:
                if ev.key.scancode == sdl.Scancode.Q || ev.key.scancode == sdl.Scancode.ESCAPE {
                    break main_loop
                }
                if ev.key.scancode == sdl.Scancode.P {
                    log.info("Rendering points")
                    sdl.SetRenderDrawColor(renderer, 255,255,255,sdl.ALPHA_OPAQUE)
                    for i in 0..=1000 {
                        renderRandomPoint(renderer)
                    }
                }
			}
		}
        sdl.RenderPresent(renderer)
	}
}

