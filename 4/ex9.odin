package main

import "core:fmt"

main :: proc() {
    age := 13

    if age <= 18 || age >= 45 {
        fmt.println("Not for you")
    }
}
