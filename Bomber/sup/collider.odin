package sup

import sdl "vendor:sdl3"

BoxCollider :: struct { 
	rect : sdl.FRect
}

Collides :: proc(lBox:^sdl.FRect, rBox:^sdl.FRect) -> bool { 
	// EWWWWWWWW
	return sdl.HasRectIntersection(sdl.Rect{ x=i32(lBox.x), y=i32(lBox.y), w=i32(lBox.w), h=i32(lBox.h)}, sdl.Rect{ x=i32(rBox.x), y=i32(rBox.y), w=i32(rBox.w), h=i32(rBox.h)})
	/** 
	lMinX := lBox.x
	lMaxX := lBox.x + lBox.w
	lMinY := lBox.y
	lMaxY := lBox.y + lBox.h
	rMinX := rBox.x
	rMaxX := rBox.x + rBox.w
	rMinY := rBox.y
	rMaxY := rBox.y + rBox.h

	if lMinX >= rMaxX { 
		return false
	}
	if lMaxX <= rMinX { 
		return false
	}

	if lMinY >= rMaxY { 
		return false
	}
	if lMaxY <= rMinX { 
		return false
	}

	return true
	*/
}

RenderBoxCollider :: proc(app: ^App, collider:^BoxCollider, color:sdl.Color)
{ 
	renderer := app.renderer
	sdl.SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
	sdl.RenderFillRect(renderer, &collider.rect)
	//  Horizontal box
	sdl.RenderFillRect(renderer, &sdl.FRect{collider.rect.x, f32(app.height - 10), collider.rect.w, 10})
	//  Vertical Box
	sdl.RenderFillRect(renderer, &sdl.FRect{0, collider.rect.y, 10, collider.rect.h})
}
