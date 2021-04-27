extends "res://src/Enemies/Enemy.gd"


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var sprite: Node2D = $Sprite
onready var collider: Node2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_velocity.x = -speed.x
	_health = 4

func move_state(delta):
	if is_on_wall():
		_velocity.x *= -1.0
		if _velocity.x > 0:
			sprite.set_scale(Vector2(-1,1))
		else:
			sprite.set_scale(Vector2(1, 1))
		collider.position = Vector2(-collider.position.x, collider.position.y)
		
	_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y
	
func attack_state(delta):
	pass
	
func stunned_state(delta):
	pass
	
func take_knockback(delta):
	pass


func _on_Hurtbox_area_entered(area):
	_health -= 1
	print_debug(_health)
	if _health == 0:
		queue_free()
	else:
		state = STUNNED
