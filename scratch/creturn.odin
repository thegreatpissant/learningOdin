package main

import "core:fmt"
import "core:time"

main :: proc() { 
	for i in 0..<100 { 
		fmt.printf("number: %d\r",i)
		time.sleep(time.Millisecond * 16)
	}
	fmt.println()
}
