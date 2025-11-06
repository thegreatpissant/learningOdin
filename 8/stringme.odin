package main

import "core:fmt"
import "core:os"

main :: proc() {
	buf: [10]byte

	fmt.print("Enter some text: ")
	os.read(os.stdin, buf[:])
	s := string(buf[:])
	fmt.println("You typed: ", s)
}
