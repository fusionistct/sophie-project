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
	
func take_knockback(delta):
	pass
