package hellosdl

import "core:fmt"
import "core:log"
import sdl "vendor:sdl3"
import strings "core:strings"

gWindow : ^sdl.Window
gSurface : ^sdl.Surface
gWindow1 : ^sdl.Window
gSurface1 : ^sdl.Surface
gWindow2 : ^sdl.Window
gSurface2 : ^sdl.Surface
gHelloWorld : ^sdl.Surface

WINDOW_WIDTH :: 400
WINDOW_HEIGHT :: 400

init :: proc() -> bool {

    success := true

    if !sdl.Init({sdl.InitFlag.VIDEO}) {
        success = false
        sdl.Log("Failed to initialize SDL %s\n", sdl.GetError())
    }
    return success
}

generateWindow :: proc (window: ^^sdl.Window, surface: ^^sdl.Surface, title: string) -> bool {
    success := true
    // Create window
    windowTitle := strings.clone_to_cstring(strings.concatenate({"SDL tutorial: ", title}))
    window^ = sdl.CreateWindow(windowTitle, WINDOW_WIDTH, WINDOW_HEIGHT, {})
    if window^ == nil {
        sdl.Log("Failed to create a window: %s", sdl.GetError())
        success = false
    } else {
        surface^ = sdl.GetWindowSurface(window^)
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
    if !generateWindow(&gWindow, &gSurface, "Nearest") {
        log.panic("Failed to generate window 0")
    }
    if !generateWindow(&gWindow1, &gSurface1, "Linear") {
        log.panic("Failed to generate Window 1")
    }
    if !generateWindow(&gWindow2, &gSurface2, "PIXELART") {
        log.panic("Failed to generate Window 1")
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
        sdl.FillSurfaceRect(gSurface, nil, sdl.MapSurfaceRGB(gSurface, 0xFF, 0x00, 0x00))
        sdl.FillSurfaceRect(gSurface1, nil, sdl.MapSurfaceRGB(gSurface, 0xFF, 0x00, 0x00))
        sdl.FillSurfaceRect(gSurface2, nil, sdl.MapSurfaceRGB(gSurface, 0xFF, 0x00, 0x00))
        sdl.BlitSurfaceScaled(gHelloWorld, nil, gSurface, nil, sdl.ScaleMode.NEAREST)
        sdl.BlitSurfaceScaled(gHelloWorld, nil, gSurface1, nil, sdl.ScaleMode.LINEAR)
        sdl.BlitSurfaceScaled(gHelloWorld, nil, gSurface2, nil, sdl.ScaleMode.INVALID)
        sdl.UpdateWindowSurface(gWindow)
        sdl.UpdateWindowSurface(gWindow1)
        sdl.UpdateWindowSurface(gWindow2)
    }
    close()
}