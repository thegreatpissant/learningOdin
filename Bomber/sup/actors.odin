package sup

import "core:fmt"
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
	direction: f32,
	width: f32,
	height: f32,
	spawnTimer: Timer,	
	spawnPoint : Position,
}

Buckets :: struct { 
	buckets : [5]^Bucket,
	position :Position,
	dirVec : f32
}

Bucket :: struct { 
	texture : ^Texture,
	collider : BoxCollider,
	position : Position,
	width: f32,
	height: f32,
	enabled: bool
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
	score : i32,
	lives: int,
}

SpawnBomb :: proc(bombs:Bombs, position: Position) { 
	//  Look for an available bomb from our bomb pool
	// linear search is fine for now
	for bomb in bombs { 
		if !bomb.enabled { 
			bomb.position.x  = position.x - bomb.width / 2
			bomb.position.y = position.y 
			bomb.collider.rect.x = bomb.position.x
			bomb.collider.rect.y = bomb.position.y
			bomb.enabled = true
			return
		}
	}
}
UpdateBombs :: proc(bombs:Bombs, deltatime: f32) {
	for bomb in bombs { 
		if bomb.enabled { 
			bomb.position.y += deltatime * bomb.speed
			bomb.collider.rect.y = bomb.position.y
		}
	}
}

UpdateBomber :: proc(bomber:^Bomber, bombs:Bombs, deltaTime: f32) { 
	//  Update position
	//  spawn bomb
	bomber.position.x += bomber.direction * deltaTime * bomber.speed
	if bomber.position.x > 640 - bomber.width { 
		bomber.direction = -1
	}
	if bomber.position.x < 0 { 
		bomber.direction = 1
	}

	if Ticked(&bomber.spawnTimer){ 
		SpawnBomb(bombs, bomber.position + bomber.spawnPoint)
	}
}

UpdateBuckets :: proc(buckets:^Buckets) { 
	for bucket in buckets.buckets { 
		bucket.position.x = buckets.position.x
		bucket.collider.rect.x = buckets.position.x
		bucket.collider.rect.w = bucket.width
	}
}
