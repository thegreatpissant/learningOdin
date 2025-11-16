package main

import "core:fmt"

main :: proc() {
    for i in 1..=30 {
	    fmt.println(i)
	    if i % 3 != 0 {
	        continue
	    }

    }
}
