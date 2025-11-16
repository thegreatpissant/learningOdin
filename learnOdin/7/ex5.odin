package main

import "core:fmt"

main :: proc() {
	for i in 1..=100 {
		if i % 3 == 0 && i % 5 == 0 {
			fmt.println("fizz buzz")
			continue
		}
	   if i % 3 == 0 {
		   fmt.println("fizz")
		   continue
	   }
	   if i % 5 == 0 {
		   fmt.println("buzz")
		   continue
	   }
	   fmt.println(i)
	}
}
