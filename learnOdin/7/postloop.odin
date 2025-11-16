package main

import "core:fmt"

main :: proc() {
	i := 0
	for i = 0; i < 5; i+= 1 {
		fmt.println(i)
	}
	fmt.println("post loop 'i': ",i)
}
