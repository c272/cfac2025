extends CharacterBody2D

# Exports.
@export var detectDist: float = 300
@export var explodeDist: float = 100
@export var damageDist: float = 100
@export var moveSpeed: float = 100

@onready var playerObj: Node2D = $"../Player"

enum State{WAITING, NOTICED, MOVING, COUNTDOWN, EXPLOSION}
var state = State.WAITING

func _process(delta: float) -> void:
	match state:
		State.WAITING:
			waiting_process(delta)
		State.NOTICED:
			noticed_process(delta)
		State.COUNTDOWN:
			countdown_process(delta)
		State.EXPLOSION:
			explosion_process(delta)

func _physics_process(delta: float) -> void:
	match state:
		State.MOVING:
			moving_physics_process(delta)
		_:
			# In other states, the character does not move.
			velocity = Vector2.ZERO
			
	move_and_slide()
	
func switch_state(newState: State):
	self.state = newState
	
	# Perform state entry callbacks.
	match newState:
		State.NOTICED:
			noticed_entered()
		State.MOVING:
			moving_entered()
		State.COUNTDOWN:
			countdown_entered()
		State.EXPLOSION:
			explosion_entered()

##################
## STATE UPDATE ##
##################

## WAITING

func waiting_process(_delta: float):
	# If the player is nowhere near us, do nothing.
	if (playerObj.global_position - global_position).length() > detectDist:
		return
	# We detected the player! Shift to noticed state.
	switch_state(State.NOTICED)

## NOTICED

func noticed_entered():
	# Turn to face the player.
	var relativeVec = playerObj.global_position - global_position
	if relativeVec.x < 0:
		$AnimatedSprite2D.flip_h = true
	
	# Play the noticed animation.
	$AnimatedSprite2D.play("Notice")
	
func noticed_process(_delta: float):
	if !$AnimatedSprite2D.is_playing():
		switch_state(State.MOVING)

## MOVING

func moving_entered():
	# Begin playing the moving animation.
	$AnimatedSprite2D.play("Move")

func moving_physics_process(_delta: float):
	# If we're close to the player, begin exploding.
	if (playerObj.global_position - global_position).length() < explodeDist:
		switch_state(State.COUNTDOWN)
		velocity = Vector2.ZERO
		return
	
	# Move towards the player.
	var toPlayer = (playerObj.global_position - global_position).normalized()
	velocity = toPlayer * moveSpeed
	pass

## COUNTDOWN

func countdown_entered():
	# Always play the countdown facing right.
	$AnimatedSprite2D.flip_h = false
	
	# Play the countdown sound.
	$CountdownPlayer.playing = true
	
	# Begin playing the countdown animation.
	$AnimatedSprite2D.play("Countdown")

func countdown_process(_delta: float):
	if !$AnimatedSprite2D.is_playing():
		switch_state(State.EXPLOSION)

## EXPLOSION

func explosion_entered():
	# Play the explosion animation.
	$AnimatedSprite2D.play("Explosion")
	
	# Play the explosion sound.
	$AudioStreamPlayer2D.playing = true
	
	# If the player is within N units of us, do damage.
	if (playerObj.global_position - global_position).length() < damageDist:
		playerObj.do_damage(Vector2.ZERO)
	
func explosion_process(_delta: float):
	if !$AnimatedSprite2D.is_playing():
		Global.current_score += 200
		queue_free()

## DAMAGE
func do_damage(_damage_pos: Vector2):
	# If we're exploding, ignore.
	if state == State.EXPLOSION:
		return
	
	# Immediately move to the explosion state.
	switch_state(State.EXPLOSION)
