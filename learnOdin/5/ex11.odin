package main

import "core:fmt"

main :: proc() {
    s := "Hellope!"

    for r in s {
	    fmt.println(r)
    }
}
