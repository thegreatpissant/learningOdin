package main

import "core:fmt"

main :: proc() {
    age := 27

    fmt.printfln("I am now %d years old.", age)

    age = age + 1
    fmt.println("A year passes")
    fmt.printfln("I am now %d years old.", age)
}
