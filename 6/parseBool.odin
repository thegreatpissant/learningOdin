package main

import "core:fmt"
import "core:strconv"

main :: proc() {
	sa := "1"
	sb := "false"
	sc := "False"
	sd := "True"
	se := "TrUe"
	fmt.println("sa: ", sa, strconv.parse_bool(sa))
	fmt.println("sb: ", sb, strconv.parse_bool(sb)) 
	fmt.println("sc: ", sc, strconv.parse_bool(sc))
	fmt.println("sd: ", sd, strconv.parse_bool(sd))
	fmt.println("se: ", se, strconv.parse_bool(se))
}
