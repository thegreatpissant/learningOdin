package sizeof

import "core:fmt"
import "core:bytes"
import "core:os"

// if n < 0, no limit on the number of removals
bytes_remove_string :: proc(b: []byte, key: string, n := 1) -> (output: []byte, was_allocation: bool) {
    return bytes.remove(b, transmute([]byte)key, n)
}

// return true on first success from strings slice, this is basically an OR
bytes_contains_string :: proc(b: []byte, strings: ..string) -> (ok: bool) {
    for s in strings {
        bs := transmute([]byte)s
        for index := 0; len(b) >= len(bs) && index <= len(b) - len(bs); index += 1 {
            if bytes.equal(b[index:index+len(s)], bs) do return true
        }
    }
    return false
}

main :: proc() {
    size_of_byte := size_of(byte)
    size_of_string := size_of(string)
    fmt.printf("Size of byte: %d, size of string: %d", size_of_byte, size_of_string)
    buf: [512]byte
    fmt.print("Enter something: ")
    bytes_read, err := os.read(os.stdin, buf[:])
    if err != nil {
        fmt.println("Failed to read from stdin: ", err)
    } else {
        newBytes, ok := bytes.remove(buf[:bytes_read], transmute([]u8)(string("no")), 1)
        if ok {
            fmt.println("Realloc occured")
        }
        message :=string(newBytes[:len(newBytes) -1])
        fmt.println("New string: ", message)
    }

    myBytes := transmute([]byte)string("these are my bytes")
    fmt.println("myBytes: ", myBytes)

}