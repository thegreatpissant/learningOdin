package sup

import "core:fmt"
import sdl "vendor:sdl3"

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
	bombsCaught : int
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

BOMBCOUNT :: 15
BOMBBLOWUPCOUNTDOWN :: 4
BOMBBLOWUPDELAY :: .5 * sdl.NS_PER_SECOND
Bombs :: [BOMBCOUNT]^Bomb

Bomb :: struct { 
	render : bool,
	enabled : bool,
	blowingUp: bool,
	position: Position,
	posX: f32,
	width: f32,
	height: f32,
	speed :f32,
	collider: BoxCollider,
	animation: ^Animation,
	idleAnimation: ^Animation,
	blowUpTexture: ^Texture,
	blowUpAnimation: ^Animation,
	blowUpTimer: Timer,
	blowUpCountdown: int
}

Player :: struct { 
	score : i32,
	lives: int,
}

BlowUpBomb:: proc(bomb:^Bomb) { 
	bomb.animation = bomb.blowUpAnimation
	bomb.animation.deltaTime = 0
	bomb.speed = 0
	bomb.blowingUp = true
	bomb.blowUpTimer.tickDelay = BOMBBLOWUPDELAY
	bomb.blowUpCountdown = BOMBBLOWUPCOUNTDOWN
	StartTimer(&bomb.blowUpTimer)
}

SpawnBomb :: proc(bombs:Bombs, bombI:int, position: Position) { 
	bombs[bombI].position.x  = position.x - bombs[bombI].width / 2
	bombs[bombI].position.y = position.y 
	bombs[bombI].enabled = true
}

UpdateBombs :: proc(bombs:Bombs, deltatime: f32) {
	for bomb in bombs { 
		if bomb.enabled { 
			bomb.position.y += deltatime * bomb.speed
			bomb.collider.rect.x = bomb.position.x
			bomb.collider.rect.y = bomb.position.y
			bomb.collider.rect.w = bomb.width
			bomb.collider.rect.h = bomb.height
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
