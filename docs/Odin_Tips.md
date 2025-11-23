# Odin Memory Management Tips

A collection of tips and best practices for handling memory in Odin, based on common pitfalls.

## 1. `free` vs. `delete`: Custom Types vs. Built-in Collections

The key distinction between `free` and `delete` is the kind of type you are working with.

### `free()` for Pointers to Single Instances (e.g., Custom Structs)

You should use `free()` to release memory for a **single instance** of a type that was allocated on the heap. This is most common when you have a pointer to a struct that you created with `new()`.

-   **Allocation**: `new(MyStruct)`
-   **Deallocation**: `free(my_struct_ptr)`

**Example:**

```odin
// Allocation of a single custom struct instance
my_texture := new(Texture)

// Correct Deallocation
free(my_texture)
```

### `delete()` for Built-in Collection Types & CStrings

You should use `delete()` to release the **internal memory buffer** of Odin's built-in collection types or cloned C-style strings. This applies to:
-   Dynamic Arrays (`[dynamic]T`)
-   Maps (`map[K]V`)
-   Slices (`[]T`) or Strings (`string`) that you created from a manual allocation.
-   `cstring`s created via cloning procedures.

`delete()` cleans up the memory that the collection manages behind the scenes.

---

## 2. Cleaning up CStrings

When you interface with C libraries, you often need to convert an Odin `string` to a null-terminated `cstring`. The `strings.clone_to_cstring` procedure is perfect for this, but it allocates new memory.

This memory must be freed using `delete()`. A common and safe pattern is to `defer` the `delete()` call immediately after the allocation to guarantee it is cleaned up when the procedure exits.

**Example:**

```odin
import "core:strings"

proc do_something_with_a_cstring(title: string) {
    // 1. Allocate the cstring
    c_title := strings.clone_to_cstring(title)
    // 2. Defer its deletion immediately to prevent leaks
    defer delete(c_title)

    // 3. Pass the cstring to a C function
    c_library.do_thing(c_title)
}
```

---

## 3. Cleaning Up Dynamic Arrays of Pointers

When working with dynamic arrays that store pointers (e.g., `[dynamic]^MyStruct`), you must perform a two-step cleanup to avoid leaks:

1.  **Free the contained elements**: Loop through the array and `free()` each pointer element individually. This cleans up the memory for each `MyStruct` instance.
2.  **Delete the array's buffer**: Use `delete()` on the array itself. This releases the underlying memory buffer that was allocated to hold the pointers.

### `clear()` vs. `delete()`

It's also crucial to understand the difference between `clear` and `delete` for dynamic arrays:

-   `clear(&my_array)`: Only sets the array's `len` to 0. It does **not** free the underlying memory buffer. This is an optimization for when you want to reuse an array's capacity, but it will cause a leak if you don't eventually `delete()` it.
-   `delete(my_array)`: Frees the underlying memory buffer used by the array.

**Complete Example:**

```odin
// app.buttons is a [dynamic]^Button

// Step 1: Free each Button the array points to
for button_ptr in app.buttons {
    free(button_ptr)
}

// Step 2: Free the array's internal storage buffer
delete(app.buttons)

// Using clear() here would leak the array's buffer:
// clear(&app.buttons) // WRONG - only sets len to 0, does not free memory
```

## 4. Using a Tracking Allocator to Find Leaks

Odin's `core:mem` package provides a `Tracking_Allocator` that is invaluable for debugging memory issues. By wrapping the `context.allocator`, it can report any memory blocks that were allocated but not freed.

**Setup in your `main` procedure:**

```odin
import "core:mem"
import "core:fmt"

main :: proc() {
    // 1. Initialize the tracker, giving it the current allocator to wrap.
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    // 2. Defer its destruction to clean up the tracker's own memory.
    defer mem.tracking_allocator_destroy(&track)

    // 3. Set it as the context's default allocator for subsequent calls.
    context.allocator = mem.tracking_allocator(&track)

    // ... your program logic ...
    // Run Init(), Loop(), Cleanup(), etc.

    // 4. At the end, print any leaks found by the tracker.
    fmt.println("--- Checking for memory leaks ---")
    for _, leak in track.allocation_map {
        fmt.printf("%v leaked %m\n", leak.location, leak.size)
    }
}
```
This will print the file location and size of any unfreed memory allocations, making it much easier to pinpoint the source of a leak.