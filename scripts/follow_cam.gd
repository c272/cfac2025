extends Camera2D

@export var followObj: Node2D
@export var smoothing: float = 0.125

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if followObj:
		self.position = Vector2(followObj.position.x, self.position.y)
