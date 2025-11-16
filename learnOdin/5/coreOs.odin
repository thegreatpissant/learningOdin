package main

import "core:fmt"
import "core:os"

main :: proc() {
	fmt.println("There are ", len(os.args) - 1, " arguments")
	for a,i in os.args[1:] {
		fmt.printfln("% 3d:%s",i,a)
	}

	fmt.println("The program name: ", os.args[0])
	fmt.println("The rest of the args: ", os.args[1:3])

	fmt.println("Names:")
	for name in os.args[1:] {
		fmt.printfln("Hello, %s", name)
	}
}
