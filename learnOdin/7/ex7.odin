package main

import "core:fmt"

main :: proc () {
	weekdays := []string{"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
	#reverse for day in weekdays {
		fmt.println(day)
	}
}
