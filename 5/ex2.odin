package main

import "core:fmt"

main :: proc() {
	values := [10]int{10, 20, 30, 40, 50, 60, 70, 80, 90, 100}

	fmt.println("20 30")
	fmt.println(values[2:4])
	fmt.println("50 through 100")
	fmt.println(values[5:10])
	fmt.println("50 through error")
	fmt.println(values[5:11])
	fmt.println("60 through wont compile")
	fmt.println(values[6:2])
}
