package functionpointers

import "core:fmt"

Hello1 :: proc() { 
	fmt.println("Hello world...One")
}
Hello2 :: proc(name:string) { 
	fmt.printfln("hello %s, two!", name)
}

PrintName :: proc(name:Name) { 
	fmt.printfln("My name is: %s %s", name.first, name.last)
}

Name :: struct { 
	first :string,
	last :string,
	PrintName :proc(Name),
}

main :: proc () { 
	a : proc() = Hello1
	b : proc(string) = Hello2

	a()
	b("Jim")

	name : Name = { 
	first = "Jim",
	last = "Part",
	PrintName = PrintName,
	}
	name.PrintName(name)
}
