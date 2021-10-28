extends "res://src/Enemies/Enemy.gd"


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var sprite: Node2D = $Sprite
onready var idleAnim: Node2D = $Sprite/Idle
onready var hurtAnim: Node2D = $Sprite/Hurt
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
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)
	
func take_knockback():
	_velocity = calculate_velocity(
		Vector2.ZERO,
		Vector2(500, 1500),
		Vector2(150, 200),
		1.0,
		Vector2(sprite.get_scale().x, -1))
	print_debug(_velocity)
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)
	print_debug(_velocity)
	yield(get_tree().create_timer(.15), "timeout")
	_velocity = Vector2.ZERO


func _on_Hurtbox_area_entered(area):
	_health -= 1
	print_debug(_health)
	idleAnim.hide()
	hurtAnim.show()
	if _health == 0:
		queue_free()
	else:
		take_knockback()
		state = STUNNED
