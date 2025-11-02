package app

import "core:fmt"
import "core:os"

main :: proc() {
	for a in os.args[1:] {
		fmt.println(a)
	}
}
