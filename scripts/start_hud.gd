extends Node2D

const AUDIO_FADE_SPEED: float = 30.0
const LOGO_FADE_SPEED: float = 2.0
const TOTAL_FADE_TIME = 1.0

@onready var gameNode = $"../Game"
@onready var hudNode = $"../HUD/Modularity"

# Whether the user has progressed yet.
var has_pressed_start = false
var time_since_pressed = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide the HUD.
	hudNode.modulate.a = 0
	$Logo.play("Start")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !has_pressed_start:
		update_before_start()
	else:
		if update_during_start(delta):
			# Make the game node enabled again.
			gameNode.process_mode = Node.PROCESS_MODE_INHERIT
			Global.game_started = true
			
			# Make the HUD full opacity.
			hudNode.modulate.a = 1
			
			# Destroy self.
			queue_free()
	
func update_before_start():
	# Was the game just started?
	if Input.is_action_just_pressed("start_game"):
		has_pressed_start = true
		
func update_during_start(delta: float) -> bool:
	# Fade out the music.
	$AudioStreamPlayer.volume_db -= AUDIO_FADE_SPEED * delta
	
	# Fade out the logo, text.
	$Logo.self_modulate.a -= LOGO_FADE_SPEED * delta
	$PressToPlayText.self_modulate.a -= LOGO_FADE_SPEED * delta
	
	# Fade in the HUD.
	hudNode.modulate.a += LOGO_FADE_SPEED * delta
	
	time_since_pressed += delta
	return time_since_pressed > TOTAL_FADE_TIME
