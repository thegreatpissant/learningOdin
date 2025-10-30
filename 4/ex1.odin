package currentTime

import "core:fmt"
import "core:time"

main :: proc() {
	fmt.printfln("%i:%i:%i",time.clock_from_time(time.now()))
}
