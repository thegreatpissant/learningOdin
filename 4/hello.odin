package main

import "core:fmt"

main :: proc() {
	helloWord := "Hello"
	helloNoun := "World"

	fmt.printfln("%s, %s", helloWord, helloNoun)
}
