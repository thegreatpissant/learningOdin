package currentTime

import "core:fmt"
import "core:time"

main :: proc() {
	a := time.now()
	fmt.println(a)
	fmt.printfln("%i:%i:%i",time.clock_from_time(time.now()))
}
