package main

import "core:fmt"

main :: proc() {
	for i := 0; i <= 150; i += 5 {
		fmt.println(i)
	}
}
