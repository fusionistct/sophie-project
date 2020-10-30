extends "res://src/Enemies/Enemy.gd"


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var sprite: Node2D = $Sprite
onready var collider: Node2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_velocity.x = -speed.x

func _physics_process(delta: float) -> void:
	_velocity.y += gravity * delta
	if is_on_wall():
		_velocity.x *= -1.0
		if _velocity.x > 0:
			sprite.set_scale(Vector2(-1,1))
		else:
			sprite.set_scale(Vector2(1, 1))
		collider.position = Vector2(-collider.position.x, collider.position.y)
		
	_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y
