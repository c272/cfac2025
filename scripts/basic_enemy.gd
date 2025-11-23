extends "res://scripts/enemy.gd"

# Exports.
@export var walkSpeed: float = 20.0

# State.
enum EnemyState{WALKING_DOWN, WALKING_UP, FIRING}
var state = EnemyState.WALKING_DOWN
var time_in_state: float = 0
var last_state = EnemyState.WALKING_DOWN

# Reference to the player.
@onready var player = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Enter initial state.
	switch_state(EnemyState.WALKING_DOWN)
	
# Per-frame update.
func _process(delta: float):
	time_in_state += delta
	match state:
		EnemyState.WALKING_DOWN, EnemyState.WALKING_UP:
			process_walking()
		EnemyState.FIRING:
			process_firing()

# Physcis update for the little man.
func _physics_process(_delta: float) -> void:
	match state:
		EnemyState.WALKING_DOWN:
			velocity = Vector2(0, walkSpeed)
		EnemyState.WALKING_UP:
			velocity = Vector2(0, -walkSpeed)
		_:
			velocity = Vector2.ZERO
	move_and_slide()

func switch_state(new_state: EnemyState):
	time_in_state = 0
	last_state = state
	state = new_state
	
	# Run callbacks for state entry.
	match state:
		EnemyState.WALKING_UP, EnemyState.WALKING_DOWN:
			walking_entered()
		EnemyState.FIRING:
			firing_entered()

## WALKING

func walking_entered():
	# Play the walking animation.
	$AnimatedSprite2D.play("Walking")

func process_walking():
	# If we've finished walking, exit state.
	if time_in_state > 2.0:
		switch_state(EnemyState.FIRING)
		return

## FIRING

func firing_entered():
	# If there's no player to fire at, ignore.
	if player and (player.global_position - global_position).length() > activateDist:
		switch_state(EnemyState.WALKING_DOWN if last_state == EnemyState.WALKING_UP else EnemyState.WALKING_UP)
		return
	
	# There's a valid player to fire at, do that now.
	fire_bullet()

func process_firing():
	# When the fire animation ends, move.
	if !$AnimatedSprite2D.is_playing():
		switch_state(EnemyState.WALKING_DOWN if last_state == EnemyState.WALKING_UP else EnemyState.WALKING_UP)
