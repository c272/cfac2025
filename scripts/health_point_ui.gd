extends CanvasGroup

@export var player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !player:
		return
		
	# Update the displayed hearts based on health.
	$Heart1.play("Full" if player.health >= 1 else "Empty")
	$Heart2.play("Full" if player.health >= 2 else "Empty")
	$Heart3.play("Full" if player.health >= 3 else "Empty")
