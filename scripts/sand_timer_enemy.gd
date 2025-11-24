extends Node2D

# Exports.
@export var fallTime: float = 1.0
@export var damageThreshTime: float = 0.9
@export var raiseTime: float = 2.0
@export var fallDist: float = 75.0

@onready var player = $"../../Player"

# State information.
enum State{WAITING, FALLING_DOWN, MOVING_UP}
var state = State.WAITING

# Enemy state.
var time_moving: float = 0.0
var right_side_up = true
var damage_dealt = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match self.state:
		State.FALLING_DOWN:
			falling_process(delta)
		State.MOVING_UP:
			moving_up_process(delta)

func switch_state(newState: State):
	self.state = newState
	match self.state:
		State.FALLING_DOWN:
			falling_entered()
		State.MOVING_UP:
			moving_up_entered()
	
#####################
## STATE FUNCTIONS ##
#####################

## FALLING

func falling_entered():
	time_moving = 0.0
	damage_dealt = false
	
	# Play the flip upside down/right up animation.
	$AnimatedSprite2D.play("Flip Upside-Down" if right_side_up else "Flip Right Side Up")
	right_side_up = !right_side_up
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "position:y", self.position.y + fallDist, fallTime)
	
func falling_process(delta: float):
	time_moving += delta
	if time_moving > damageThreshTime and !damage_dealt:
		apply_falling_damage()
	
	if time_moving > fallTime:
		switch_state(State.MOVING_UP)
		
func apply_falling_damage():
	var bodies = $HitArea.get_overlapping_bodies()
	for body in bodies:
		if body != player:
			continue
		# Do damage to the player.
		player.do_damage()
		damage_dealt = true
	
## MOVING UP
	
func moving_up_entered():
	# Go back to the idle animation.
	$AnimatedSprite2D.play("Idle" if right_side_up else "Idle Upside-Down")
	
	time_moving = 0.0
	pass
	
func moving_up_process(delta: float):
	position.y -= (fallDist / fallTime) * delta
	time_moving += delta
	if time_moving > fallTime:
		switch_state(State.WAITING)

#############
## SIGNALS ##
#############

# Triggered when the detect area is entered.
func _on_detect_area_body_entered(body: Node2D) -> void:
	if body != player or state != State.WAITING:
		return
	# The player entered the detector zone.
	switch_state(State.FALLING_DOWN)
