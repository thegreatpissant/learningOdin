package main

import "core:fmt"
import "core:os"

main :: proc() {
	buf: [100]byte

	fmt.print("Enter a language: ")
	bufLen, err := os.read(os.stdin, buf[:])
	if err != nil {
		fmt.eprintln("Failed to read stdin")
		os.exit(-1)
	}
	fmt.printfln("%s is done right!", buf[:bufLen - 1])
}
