package appInit

import "core:log"
import "base:runtime"
import sdl "vendor:sdl3"

window : ^sdl.Window
renderer : ^sdl.Renderer
appWidth :f32= 200
posx : f32
posy : f32
dirR := false

sdl_init :: proc "c" (appstate: ^rawptr, argc: i32, argv: [^]cstring) -> sdl.AppResult { 
	context = runtime.default_context()
	ok := sdl.Init({ .VIDEO})
	if !ok { 
		log.panicf("Failed to init %s", sdl.GetError())
	}
	window = new(sdl.Window)
	renderer = new(sdl.Renderer)

	ok = sdl.CreateWindowAndRenderer("Hello Callback SDL3", i32(appWidth), i32(appWidth), { }, &window, &renderer)
	if !ok { 
		log.panic("Fialed to create window and renderer", sdl.GetError())
	}
	if !sdl.SetRenderVSync(renderer, 1) { 
		log.info("Failed to set vsync")
	}
	posx = 0
	posy = 0
	return sdl.AppResult.CONTINUE
}

app_iterate :: proc "c" (appstate: rawptr) -> sdl.AppResult { 
	context = runtime.default_context()
	sdl.SetRenderDrawColor(renderer, 0x0, 0x0, 0x0, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(renderer)
	sdl.SetRenderDrawColor(renderer, 0xFF, 0x0, 0x0, sdl.ALPHA_OPAQUE)
	sdl.RenderLine(renderer, posx,posy, appWidth - posx, appWidth - posy)
	sdl.RenderLine(renderer, posx,appWidth - posy, appWidth - posx, posy)
	if dirR { 
		posx += 1
		if posx >= appWidth { 
			dirR = false
		}
	} else { 
		posx -= 1
		if posx <= 0 { 
			dirR = true
		}
	}

	sdl.RenderPresent(renderer)
	return sdl.AppResult.CONTINUE
}

event_callback :: proc "c" (appstate: rawptr, event:^sdl.Event) -> sdl.AppResult { 
	context = runtime.default_context()
	#partial switch event.type { 
	case sdl.EventType.QUIT:
		return sdl.AppResult.FAILURE
	case sdl.EventType.KEY_DOWN:
		#partial switch event.key.scancode{ 
		case sdl.Scancode.Q:
			return sdl.AppResult.SUCCESS
		}
	}
	return sdl.AppResult.CONTINUE
}

app_quit :: proc "c" (appstate: rawptr, result: sdl.AppResult) -> sdl.AppResult { 
	context = runtime.default_context()
	return sdl.AppResult.SUCCESS
}

main :: proc() { 
	argv :cstring= ""
	sdl.EnterAppMainCallbacks(0, &argv, sdl_init,app_iterate,event_callback,nil)
}
