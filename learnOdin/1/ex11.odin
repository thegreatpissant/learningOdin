package main

import "core:fmt"

main :: proc() {
    a := 5
    b := 0

    fmt.println("a + b =", a+b)
    fmt.println("a - b =", a-b)
    fmt.println("a * b =", a*b)
    fmt.println("a / b =", a/b)
}
