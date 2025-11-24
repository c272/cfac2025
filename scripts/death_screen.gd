extends CanvasLayer

@export var delayTime: float = 1.0
@export var fadeBackTime: float = 2.0
@export var fadeForeTime: float = 0.5
@export var audioFadeSpeed: float = 10.0

enum State{IDLE, DELAY, FADING_BACK, FADING_FORE, AWAITING_INPUT}
var state = State.IDLE

var cur_delay_time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide self.
	self.visible = false
	
	# Modulate all children to zero.
	$ColorRect.self_modulate.a = 0
	$AnimatedSprite2D.self_modulate.a = 0
	$RichTextLabel.self_modulate.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		State.DELAY:
			delay_process(delta)
		State.FADING_BACK:
			fade_back_process(delta)
		State.FADING_FORE:
			fade_fore_progress(delta)
		State.AWAITING_INPUT:
			await_input_process(delta)
			
func delay_process(delta: float):
	cur_delay_time += delta
	if cur_delay_time > delayTime:
		state = State.FADING_BACK
	
func fade_back_process(delta: float):
	var fadeDelta = delta / fadeBackTime;
	$ColorRect.self_modulate.a = min(1.0, $ColorRect.self_modulate.a + fadeDelta)
	if $ColorRect.self_modulate.a >= 1.0:
		state = State.FADING_FORE
	
	# Hack: Also fade down the BGM.
	$"../Game/AudioStreamPlayer2D".volume_db -= delta * audioFadeSpeed
	
func fade_fore_progress(delta: float):
	var fadeDelta = delta / fadeForeTime;
	$AnimatedSprite2D.self_modulate.a = min(1.0, $AnimatedSprite2D.self_modulate.a + fadeDelta)
	$RichTextLabel.self_modulate.a = min(1.0, $RichTextLabel.self_modulate.a + fadeDelta)
	if $AnimatedSprite2D.self_modulate.a >= 1.0:
		state = State.AWAITING_INPUT
		
func await_input_process(_delta: float):
	if Input.is_action_just_pressed("start_game"):
		get_tree().call_deferred("reload_current_scene")

# Begins the fade in effect for the death screen.
func fade_in():
	# If we're not in the idle state, ignore.
	if state != State.IDLE:
		return
	
	# Play the death animation.
	$AnimatedSprite2D.play("Death")
	
	# Show self, change state.
	self.visible = true
	state = State.DELAY
