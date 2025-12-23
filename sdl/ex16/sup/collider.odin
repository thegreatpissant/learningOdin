package sup

import sdl "vendor:sdl3"

BoxCollider :: struct { 
	rect : sdl.FRect
}

Collides :: proc(lBox:^BoxCollider, rBox:^BoxCollider) -> bool { 
	lMinX := lBox.rect.x
	lMaxX := lBox.rect.x + lBox.rect.w
	lMinY := lBox.rect.y
	lMaxY := lBox.rect.y + lBox.rect.h
	rMinX := rBox.rect.x
	rMaxX := rBox.rect.x + rBox.rect.w
	rMinY := rBox.rect.y
	rMaxY := rBox.rect.y + rBox.rect.h

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
