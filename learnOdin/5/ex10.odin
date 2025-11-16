package main

import "core:fmt"
import "core:os"

main :: proc () {
	fmt.println("file name: ", os.args[0])
}
