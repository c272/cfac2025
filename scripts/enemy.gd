extends CharacterBody2D

# Bullet prefab.
const BULLET_SCENE: PackedScene = preload("res://prefabs/BEBullet.tscn")

# Exported variables.
@export var maxHealth: int = 1
@export var fireOffset: Vector2 = Vector2(-30, 0)
@export var activateDist: float = 1280

var time_since_attack = 0
var health = 0
var bullet_spawn_pending: bool = false

func _ready() -> void:
	# Update our health.
	self.health = maxHealth

func _physics_process(_delta: float) -> void:
	move_and_slide()

func fire_bullet():
	# Play the bullet firing animation.
	self.bullet_spawn_pending = true
	$AnimatedSprite2D.play("Attack")

func do_damage(_damage_pos: Vector2):
	self.health -= 1
	# Kill ourselves.
	# TODO: Animations etc.
	if self.health <= 0:
		Global.current_score += 150
		queue_free()

# Triggered when the enemy finishes an animation.
func _on_animation_finished() -> void:
	# Spawn the bullet.
	if self.bullet_spawn_pending:
		var bullet = BULLET_SCENE.instantiate()
		bullet.position = position + self.fireOffset
		bullet.direction = Vector2(-1, 0)
		add_sibling(bullet)
