extends KinematicBody2D
class_name Enemy 

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
const FLOOR_NORMAL = Vector2.UP

export var speed = Vector2(300.0, 1000.0)
export var gravity = 4000.0

var _velocity = Vector2.ZERO
var _health = 0

enum {
	MOVE,
	ATTACK,
	STUNNED
}

onready var state = MOVE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta):
	_velocity.y += gravity * delta
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		STUNNED:
			stunned_state(delta)

func move_state(delta):
	pass
	
func attack_state(delta):
	pass
	
func stunned_state(delta):
	pass
	
func take_knockback():
	pass

#Copy + pasted from Move StateMachine code. Refactor as utility function later
static func calculate_velocity(
		old_velocity: Vector2,
		max_speed: Vector2,
		acceleration: Vector2,
		delta: float,
		move_direction: Vector2
	) -> Vector2:
	var new_velocity = old_velocity
	print_debug("old velocity: ", old_velocity)
	new_velocity += move_direction * acceleration * delta
	print_debug("new velocity: ", new_velocity)
	new_velocity.x = clamp(new_velocity.x, -max_speed.x, max_speed.x)
	new_velocity.y = clamp(new_velocity.y, -max_speed.y, max_speed.y)
	print_debug("after clamping: ", new_velocity)
	return new_velocity
