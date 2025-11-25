extends Area2D

@export var direction: Vector2 = Vector2(1, 0)
@export var speed: float = 150.0
@export var move_anim: String
@export var hit_anim: String
@export var is_from_enemy = false
@export var max_lifetime = 30.0

var lifetime = 0.0
var has_hit = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Play the move animation.
	$AnimatedSprite2D.play(move_anim)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Manage the lifetime of the bullet.
	lifetime += delta
	
	if !has_hit:
		if lifetime > max_lifetime:
			has_hit = true
			$AnimatedSprite2D.play(hit_anim)
		
		# Update position.
		global_position += direction * speed * delta * Global.time_multiplier
	else:
		if !$AnimatedSprite2D.is_playing():
			queue_free()

# Triggered when a body is entered.
func _on_body_entered(body: Node2D) -> void:
	# If the bullet is from an enemy and damaging another enemy, ignore.
	if is_from_enemy and body.name.contains("Enemy"):
		return

	# Attempt to do damage to the collided body.
	if body.has_method("do_damage"):
		body.do_damage(global_position)
	
	# Play hit animation.
	has_hit = true
	$AnimatedSprite2D.play(hit_anim)
