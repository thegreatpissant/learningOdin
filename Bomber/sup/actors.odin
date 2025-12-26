package sup

import "vendor:sdl3"


/*
   bomber at the top
   - random walk between app width and height
   - enables a bomb

   Bomb 
   - enabled at position
   - falls at constant rate
   - collides with bucket
   - collides with bottom of screen

   Bucket
   - Moved by player
   - collides with bomb
   - collides with left and right side of the screen

*/

// Actors
Bomber :: struct { 
	running: bool,
	texture : ^Texture,
	speed: f32,
	bombcount: i32,
	position: Position,
	width: f32,
	height: f32,
	spawnTimer: Timer,	
	spawnPoint : Position,
}

Bucket :: struct { 
	texture : ^Texture,
	collider : BoxCollider,
	position : Position,
	width: f32,
	height: f32
}

Bombs :: [dynamic]^Bomb

Bomb :: struct { 
	enabled : bool,
	position: Position,
	width: f32,
	height: f32,
	speed :f32,
	texture: ^Texture,
	collider: BoxCollider
}

Player :: struct { 
	points : i32,
}

SpawnBomb :: proc(bombs:Bombs, position: Position) { 
	//  Look for an available bomb from our bomb pool
	// linear search is fine for now
	for bomb in bombs { 
		if !bomb.enabled { 
			bomb.position = position
			bomb.enabled = true
		}
	}
}
UpdateBombs :: proc(bombs:Bombs, deltatime: u64) { 
}

UpdateBomber :: proc(bomber:^Bomber, bombs:Bombs, deltaTime: u64) { 
	//  Update position
	//  spawn bomb
	if Ticked(&bomber.spawnTimer){ 
		SpawnBomb(bombs, bomber.position)
	}
	
}

