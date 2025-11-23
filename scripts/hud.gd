extends CanvasLayer

# Speed of the points add decay.
const POINTS_ADD_DECAY_SPEED = 1.0

@onready var last_score = Global.current_score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Modularity/PointsAdd.self_modulate.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Modularity/TextureProgressBar.value = 100 * (Global.time_modify_gauge_time / Global.TIME_GAUGE_MAX_TIME)
	
	# Decrease modularity for points add label.
	if $Modularity/PointsAdd.self_modulate.a > 0:
		$Modularity/PointsAdd.self_modulate.a = max(0, $Modularity/PointsAdd.self_modulate.a - POINTS_ADD_DECAY_SPEED * delta)

	# If required, update the points label.
	if Global.current_score != last_score:
		update_score(Global.current_score - last_score)
		last_score = Global.current_score

# Update score.
func update_score(points: int):
	# Show the "+points" indicator.
	$Modularity/PointsAdd.text = "+" + str(points)
	$Modularity/PointsAdd.self_modulate.a = 1
	
	# Update the text.
	$Modularity/Label.text = str(Global.current_score).lpad(10, "0")
