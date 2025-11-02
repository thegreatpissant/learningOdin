package main

import "core:fmt"
import "core:os"

main :: proc() {
    if len(os.args[1:]) < 1 {
	    fmt.println("You must provide a command-line argument")
	    os.exit(-1)
    } else if len(os.args[1:]) > 1 {
	    fmt.println("You provided too much information")
	    os.exit(-1)
    }

    if os.args[1] == "false" {
	    fmt.println("I cannot continue")
    } else {
	    fmt.println("Welcome!")
    }
}
