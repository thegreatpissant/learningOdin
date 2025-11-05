package main

import "core:fmt"

main :: proc() {
	i := 0
	for {
		i += 1
		fmt.println("i: ", i)
		if i > 10 {
			break
		}
	}
}
