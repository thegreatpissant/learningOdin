package main

import "core:fmt"

main :: proc() {
	for i := 10; i > 0; i -= 1 {
		fmt.println(i)
	}
}
