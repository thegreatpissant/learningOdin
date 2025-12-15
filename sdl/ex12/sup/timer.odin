package sup

import sdl "vendor:sdl3"

Timer :: struct {
	tickDelay:  u64,
	prevTick:   u64,
	startTicks: u64,
	pauseTicks: u64,
	started:    bool,
	paused:     bool,
}

StartTimer :: proc(timer: ^Timer) {
	timer.started = true
	timer.paused = false
	timer.startTicks = sdl.GetTicksNS()
	timer.pauseTicks = 0
}
StopTimer :: proc(timer: ^Timer) {
	timer.started = false
	timer.paused = false
	timer.startTicks = 0
	timer.pauseTicks = 0
}

ToggleTimer :: proc(timer: ^Timer) {
	if timer.started {
		StopTimer(timer)
	} else {
		StartTimer(timer)
	}
}

PauseTimer :: proc(timer: ^Timer) {
	if timer.paused {
		return
	}
	timer.paused = true
	timer.pauseTicks = sdl.GetTicksNS() - timer.startTicks
	timer.startTicks = 0
}

UnPauseTimer :: proc(timer: ^Timer) {
	if !timer.paused {
		return
	}
	timer.paused = false
	ticks := sdl.GetPerformanceCounter()
	timer.startTicks = ticks - timer.pauseTicks
	timer.pauseTicks = 0
}

TogglePauseTimer :: proc(timer: ^Timer) {
	if timer.paused {
		UnPauseTimer(timer)
	} else {
		PauseTimer(timer)
	}
}

GetTicks :: proc(timer: ^Timer) -> u64 {
	if timer.started {
		if timer.paused {
			return timer.pauseTicks
		} else {
			return sdl.GetPerformanceCounter() - timer.startTicks
		}
	}
	return 0
}

