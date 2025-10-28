package main

import "core:fmt"

main :: proc() {
	fmt.println("10..<10")
	for i in 10..<10{
	//  invalid interval range
		fmt.println("%i",i)
	}

	fmt.println("nested for range operators")	
	for i in 1..<10 {
		for j in 10..<i {
			// print up to and including or not at all
			fmt.printfln("i: %i, j: %i", i, j)
		}
	}
}
