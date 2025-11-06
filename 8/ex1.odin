package main

import "core:fmt"
import "core:os"

main :: proc() {
	buf:[100]byte
	fmt.print("Enter your name: ")
	bufLen, err := os.read(os.stdin,buf[:])
	if err != nil {
		fmt.eprintf("Failed to read input")
		os.exit(-1)
	}
	fmt.println("Hello ", buf[:bufLen - 1])
	fmt.printfln("Hello %s!", buf[:bufLen - 1])
}
