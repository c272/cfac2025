extends CharacterBody2D

# Exports.
@export var detectDist: float = 300
@export var explodeDist: float = 100
@export var damageDist: float = 100
@export var moveSpeed: float = 50
@export var retreatTime: float = 2.5

@onready var playerObj: Node2D = $"../Player"

enum State{WAITING, CHASING, RETREATING}
var state = State.WAITING

var time_retreating = 0.0
var retreat_forever = false

func _process(delta: float) -> void:
	match state:
		State.WAITING:
			waiting_process(delta)
		State.RETREATING:
			retreating_process(delta)
			
func _physics_process(delta: float):
	match state:
		State.CHASING:
			chasing_physics_process(delta)
		State.RETREATING:
			retreating_physics_process(delta)
		_:
			velocity = Vector2.ZERO
	move_and_slide()
			
func switch_state(newState: State):
	self.state = newState
	
	# Perform state entry callbacks.
	match newState:
		State.CHASING:
			chasing_entered()

##################
## STATE UPDATE ##
##################

## WAITING

func waiting_process(_delta: float):
	# If the player is nowhere near us, do nothing.
	if !playerObj or (playerObj.global_position - global_position).length() > detectDist:
		return
	# We detected the player! Shift to noticed state.
	switch_state(State.CHASING)

## CHASING

func chasing_entered():
	# Begin playing the moving animation.
	$AnimatedSprite2D.play("Movement")
	
func chasing_physics_process(_delta: float):
	# Look at the player.
	var toPlayer = (playerObj.global_position - global_position)
	rotation = toPlayer.angle()
	$AnimatedSprite2D.flip_v = global_rotation_degrees > 90 or global_rotation_degrees < -90
		
	# Adjust our rope's gravity.
	$Rope.gravity_direction = Vector2(-cos(rotation), -sin(rotation))
	
	# Move towards the player.
	velocity = toPlayer.normalized() * moveSpeed * Global.time_multiplier
	
## RETREATING
func retreating_entered():
	time_retreating = 0.0
	
	# Begin playing the moving animation.
	$AnimatedSprite2D.play("Movement")
	
func retreating_process(delta: float):
	# Go back to chasing after a set amount of time.
	time_retreating += delta
	if time_retreating > retreatTime and !retreat_forever:
		switch_state(State.CHASING)

func retreating_physics_process(_delta: float):
	# Look away from the player.
	var toPlayer = (playerObj.global_position - global_position)
	rotation = toPlayer.angle() + PI
	$AnimatedSprite2D.flip_v = global_rotation_degrees > 90 or global_rotation_degrees < -90
		
	# Adjust our rope's gravity.
	$Rope.gravity_direction = Vector2(-cos(rotation), -sin(rotation))
	
	# Move away from the player.
	velocity = -toPlayer.normalized() * moveSpeed * Global.time_multiplier

## DAMAGE
func do_damage():
	# TODO: Heath
	queue_free()

# When a body enters the damage area.
func _on_area_2d_body_entered(body: Node2D) -> void:
	# If the body entered was the player, do damage.
	if body == playerObj:
		playerObj.do_damage()
		switch_state(State.RETREATING)
		
		# If the player died, never return from a retreating state.
		if playerObj.health <= 0:
			retreat_forever = true
