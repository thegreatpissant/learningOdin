package sup

import "core:fmt"
import "vendor:sdl3"

Bomber :: struct { 
	texture : ^Texture,
	speed: f32,
	bombcount: i32,
	position: Position,
	direction: f32,
	width: f32,
	height: f32,
	spawnTimer: Timer,	
	spawnPoint : Position,
	nextBomb : int,
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

Bombs :: [10]^Bomb

Bomb :: struct { 
	enabled : bool,
	position: Position,
	posX: f32,
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

SpawnBomb :: proc(bombs:Bombs, bombI:int, position: Position) { 
	bombs[bombI].position.x  = position.x - bombs[bombI].width / 2
	bombs[bombI].position.y = position.y 
	bombs[bombI].collider.rect.x = bombs[bombI].position.x
	bombs[bombI].collider.rect.y = bombs[bombI].position.y
	bombs[bombI].enabled = true
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
	bomber.position.x += bomber.direction * deltaTime * bomber.speed
	if bomber.position.x > 640 - bomber.width { 
		bomber.direction = -1
	}
	if bomber.position.x < 0 { 
		bomber.direction = 1
	}

	if Ticked(&bomber.spawnTimer){ 
		bomber.nextBomb -= 1
		if bomber.nextBomb >= 0 { 
			SpawnBomb(bombs, bomber.nextBomb, bomber.position + bomber.spawnPoint)
		}
	}
}

UpdateBuckets :: proc(buckets:^Buckets) { 
	for bucket in buckets.buckets { 
		bucket.position.x = buckets.position.x
		bucket.collider.rect.x = buckets.position.x
		bucket.collider.rect.w = bucket.width
	}
}
