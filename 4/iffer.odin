package iffer

import "core:fmt"

main :: proc() {
	knows_odin :bool= false

	if knows_odin {
		fmt.println("Oh, You know Odin. That's great news!")
	} else {
		fmt.println("Oh, You don't know Odin. Then lets start learning.")
	}
}
