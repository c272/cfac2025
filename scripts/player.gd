extends CharacterBody2D

# Bullet prefab.
const BULLET_SCENE: PackedScene = preload("res://prefabs/CBullet.tscn")

# Constants.
const TIME_MUL_SPEED: float = 2.0

# Exported variables.
@export var speed = 150
@export var can_shoot = true
@export var can_shield = true
@export var can_melee = true

# Player state information.
enum PlayerState{MOVING, SHOOTING, SHIELD, MELEE, DAMAGE, DEAD, MOVEMENT_LOCKED}
var state: PlayerState = PlayerState.MOVING

# Player state.
var health: int = 3
var melee_cur_anim = null

######################
## UPDATE FUNCTIONS ##
######################

# Update function.
func _process(delta: float) -> void:
	# Process individual states.
	match state:
		PlayerState.MOVING:
			moving_process(delta)
		PlayerState.SHOOTING:
			shooting_process(delta)
		PlayerState.SHIELD:
			shield_process(delta)
		PlayerState.MELEE:
			melee_process(delta)
		PlayerState.DAMAGE:
			damage_process(delta)
		PlayerState.DEAD:
			dead_process(delta)
	
	# Process updates to the time multiplier.
	update_time_multiplier(delta)


# Physics update function.
func _physics_process(delta: float) -> void:
	# Run per-state functions.
	if self.state == PlayerState.MOVING:
		moving_physics_process(delta)
	else:
		# In all other states, we cannot move.
		velocity = Vector2.ZERO
			
	# Update the character body.
	move_and_slide()
	
#####################
## STATE SWITCHING ##
#####################

func switch_state(new_state: PlayerState) -> void:
	self.state = new_state
	# Run callbacks.
	match new_state:
		PlayerState.SHOOTING:
			shooting_entered()
		PlayerState.SHIELD:
			shield_entered()
		PlayerState.MELEE:
			melee_entered()
		PlayerState.DAMAGE:
			damage_entered()
		PlayerState.DEAD:
			dead_entered()

#####################
## STATE FUNCTIONS ##
#####################

## MOVE

# Process function for movement.
func moving_process(_delta: float):
	# If the user has pressed the fire button, enter fire mode.
	if can_shoot and Input.is_action_just_pressed("fire"):
		switch_state(PlayerState.SHOOTING)
		return
		
	# If the user has pressed the shield button, enter shield mode.
	if can_shield and Input.is_action_just_pressed("shield"):
		switch_state(PlayerState.SHIELD)
		return
		
	# If the user has pressed the melee button, enter melee mode.
	if can_melee and Input.is_action_just_pressed("melee"):
		switch_state(PlayerState.MELEE)
		return

# Physics process function for movement.
func moving_physics_process(_delta: float):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	if velocity.length() > 0:
		$AnimatedSprite2D.play("Running")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		$AnimatedSprite2D.play("Idle")

## SHOOTING

# Called when the shooting state is entered.
func shooting_entered():
	# Begin the shooting animation.
	$AnimatedSprite2D.play("Shooting")
	
	# Play the fire sound.
	$FireSoundPlayer.playing = true
	
	# Determine the direction the bullet will go in.
	var bulletDir = -1 if $AnimatedSprite2D.flip_h else 1
	
	# Instantiate and fire a bullet.
	var bullet = BULLET_SCENE.instantiate()
	bullet.position = position + Vector2(bulletDir * 30, -5)
	bullet.direction = Vector2(bulletDir, 0)
	add_sibling(bullet)

# Called when the shooting state should process.
func shooting_process(_delta: float):
	if !$AnimatedSprite2D.is_playing():
		switch_state(PlayerState.MOVING)
		
## SHIELD

func shield_entered():
	# Play the shield animation.
	$AnimatedSprite2D.play("Shield")
	pass
	
func shield_process(_delta: float):
	# If the user isn't pressing the shield key, exit.
	if !Input.is_action_pressed("shield"):
		switch_state(PlayerState.MOVING)
		
	# Update direction.
	var dir = Input.get_vector("left", "right", "up", "down")
	if dir.x != 0:
		$AnimatedSprite2D.flip_h = dir.x < 0
		
## MELEE

func melee_entered():
	# Reset melee state.
	melee_cur_anim = "MeleeForward"
	
	# Play the initial melee animation.
	$AnimatedSprite2D.play("MeleeForward")
	
func melee_process(_delta: float):
	if !$AnimatedSprite2D.is_playing():
		# If we just finished the forward animation, play the final animation.
		if melee_cur_anim == "MeleeForward":
			$AnimatedSprite2D.play("MeleeHit")
			melee_cur_anim = "MeleeHit"
			# Perform damage.
			melee_do_damage()
		elif melee_cur_anim == "MeleeHit":
			# Begin playing the final pull in animation.
			$AnimatedSprite2D.play("MeleeFinal")
			melee_cur_anim = "MeleeFinal"
		else:
			# Return to moving state.
			melee_cur_anim = null
			switch_state(PlayerState.MOVING)
			
func melee_do_damage():
	# Find overlapping bodies, damage them.
	var bodies = $MeleeArea.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("do_damage"):
			body.do_damage()

## DAMAGE

# Adds damage to the player.
func do_damage():
	# If the player is already in an invulnerable state, ignore.
	match self.state:
		PlayerState.DAMAGE, PlayerState.DEAD, PlayerState.MOVEMENT_LOCKED:
			return
	
	# Do damage, update our own state.
	self.health -= 1
	if health <= 0:
		switch_state(PlayerState.DEAD)
	else:
		switch_state(PlayerState.DAMAGE)
	
func damage_entered():
	$AnimatedSprite2D.play("Injured")
	pass
	
func damage_process(_delta: float):
	# Move back to movement state when animation finishes.
	if !$AnimatedSprite2D.is_playing():
		switch_state(PlayerState.MOVING)
	
## DEAD

func dead_entered():
	# Die.
	$AnimatedSprite2D.play("Death")
	
	# Show the death screen.
	$"../../DeathScreen".fade_in()
	
func dead_process(_delta: float):
	pass


## TIME MULTIPLIER

# Updates the current time multiplier.
func update_time_multiplier(delta: float):
	# Determine whether we're slowing time.
	var is_slowing_time = false
	if Input.is_action_pressed("timeslow") and Global.can_modify_time:
		Global.time_modify_gauge_time = max(Global.time_modify_gauge_time - delta, 0);
		is_slowing_time = true if Global.time_modify_gauge_time > 0 else false
		Global.can_modify_time = is_slowing_time
	elif !Global.can_modify_time or !Input.is_action_pressed("timeslow"):
		# Update whether we can modify time again.		
		Global.time_modify_gauge_time = min(Global.time_modify_gauge_time + delta, Global.TIME_GAUGE_MAX_TIME);
		Global.can_modify_time = Global.time_modify_gauge_time >= Global.TIME_GAUGE_MAX_TIME
		
	# Determine the delta to the slow value.
	var dir = -1 if is_slowing_time else 1
	var timeMultDelta = TIME_MUL_SPEED * delta * dir
	Global.time_multiplier = clamp(Global.time_multiplier + timeMultDelta, -1.0, 1.0)

## MOVEMENT LOCK
func lock_movement():
	# Play the idle animation.
	$AnimatedSprite2D.play("Idle")
	switch_state(PlayerState.MOVEMENT_LOCKED)
