package hellosdl

import "core:fmt"
import "core:log"
import sdl "vendor:sdl3"

gWindow : ^sdl.Window
gSurface : ^sdl.Surface
gHelloWorld : ^sdl.Surface

WINDOW_WIDTH :: 400
WINDOW_HEIGHT :: 400

init :: proc() -> bool {

    success := false

    if !sdl.Init({sdl.InitFlag.VIDEO}) {
        sdl.Log("Failed to initialize SDL %s\n", sdl.GetError())
    } else {
        // Create window
        gWindow = sdl.CreateWindow("SDL tutorial: Hello SDL3", WINDOW_WIDTH, WINDOW_HEIGHT, {})
        if gWindow == nil {
            sdl.Log("Failed to create a window: %s", sdl.GetError())
        } else {
            gSurface = sdl.GetWindowSurface(gWindow)
            success = true
        }
    }
    return success
}

loadMedia :: proc() -> bool {
    success := true
    imagePath :cstring= "./images/hello-sdl3.bmp"
    gHelloWorld = sdl.LoadBMP(imagePath)
    if gHelloWorld == nil {
        sdl.Log("Unable to load image %s : %s ", imagePath, sdl.GetError())
        success = false
    }
    return success
}

close :: proc() {
    sdl.DestroySurface(gHelloWorld)
    gHelloWorld = nil
    sdl.DestroyWindow(gWindow)
    gWindow = nil
    gSurface = nil
    sdl.Quit()
}

main :: proc() {
    context.logger = log.create_console_logger()
    if !init() {
        log.panicf("Failed to initialize SDL")
    }
    if !loadMedia() {
        log.panic("Failed to load media")
    }
    event := new(sdl.Event)
    quit := false
    for quit == false {
        sdl.zerop(event)
        for sdl.PollEvent(event) == true {
            if event.type == sdl.EventType.KEY_DOWN {
                if event.key.scancode == sdl.Scancode.ESCAPE {
                    sdl.Log("Quiting")
                    quit = true
                }
            }
        }
        sdl.FillSurfaceRect(gSurface, nil, sdl.MapSurfaceRGB(gSurface, 0xFF, 0xFF, 0xFF))
        sdl.BlitSurface(gHelloWorld, nil, gSurface, nil)
        sdl.UpdateWindowSurface(gWindow)
    }
    close()
}