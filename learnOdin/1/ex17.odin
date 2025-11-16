package main

import "core:fmt"

main :: proc() {
	for c in 'A'..<'Z' {
		if c != 'T' {
			fmt.println(c)
		}
	}
}
