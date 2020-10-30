extends KinematicBody2D
class_name Enemy 

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
const FLOOR_NORMAL = Vector2.UP

export var speed = Vector2(300.0, 1000.0)
export var gravity = 4000.0

var _velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
