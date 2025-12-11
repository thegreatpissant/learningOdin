package sup

import sdl "vendor:sdl3"

StartTimer :: proc(timer:^Timer){ 
	timer.started = true
	timer.paused = false
	timer.startTicks = sdl.GetTicksNS()
	timer.pauseTicks = 0
}
StopTimer :: proc(timer:^Timer) { 
	timer.started = false
	timer.paused = false
	timer.startTicks = 0
	timer.pauseTicks = 0
}

ToggleTimer :: proc(timer:^Timer) { 
	if timer.started { 
		StopTimer(timer)
	} else { 
		StartTimer(timer)
	}
}
