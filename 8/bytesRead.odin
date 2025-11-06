package main

import "core:fmt"
import "core:os"

main :: proc() {
	buf: [100]byte

	fmt.print("Enter a language: ")
	buffLen, _ := os.read(os.stdin, buf[:])
	fmt.printfln("%s is a language done right!", buf[:buffLen-1])
}
