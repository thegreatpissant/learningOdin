package main

import "core:fmt"

main :: proc() {
	for i:= 100; i >= 5; i-=5 {
		fmt.println(i)
	}
}
