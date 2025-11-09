package main

import "core:log"
import sdl "vendor:sdl3"

main :: proc() {
	context.logger = log.create_console_logger()

	ok := sdl.Init({.VIDEO})
	if !ok { 
		log.panicf("Could not init SDL {}", sdl.GetError())
	}

	window := new(sdl.Window)
	renderer := new(sdl.Renderer)

	ok = sdl.CreateWindowAndRenderer("Hello SDL3", 1200, 760,{}, &window, &renderer)
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
					break main_loop
		   }
		}
	}
}
