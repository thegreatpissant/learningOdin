package main

import "core:fmt"

main :: proc() {
	for i := 0; i <= 200; i+= 10 {
		fmt.println(i)
	}
}
