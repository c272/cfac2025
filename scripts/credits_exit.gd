extends Area2D

@onready var player = $"../Player"

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		get_tree().call_deferred("change_scene_to_file", "res://sandbox.tscn")
