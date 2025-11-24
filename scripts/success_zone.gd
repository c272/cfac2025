extends Area2D

@onready var player = $"../Player"
@onready var winScreen = $"../../WinScreen"

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		# Show the win screen, lock all player movement.
		player.lock_movement()
		winScreen.fade_in()
