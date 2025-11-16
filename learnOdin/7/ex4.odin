package main

import "core:fmt"

main :: proc() {
	for i in 1..=100 {
		if i % 7 == 0 {
			fmt.println(i)
		}
	}
}
