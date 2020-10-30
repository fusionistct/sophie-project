extends State

"""
Written using GDQuest's platformer tutorial.

Parent state that abstracts and handles basic movement.
Move-related children states can delegate movement to it, or use its utility functions.
"""

export var max_speed_default = Vector2(500.0, 1500.0)
export var acceleration_default = Vector2(100000.0, 3000.0)
export var jump_impulse = 900.0

var acceleration = acceleration_default
var max_speed = max_speed_default
var velocity = Vector2.ZERO
var knockback = false

func unhandled_input(event: InputEvent) -> void:
	if owner.is_on_floor() and event.is_action_pressed("jump"):
		_state_machine.transition_to("Move/Air", { impulse = jump_impulse })

func physics_process(delta: float) -> void:
	var move_direction = Vector2.ZERO if knockback else get_move_direction()
	velocity = calculate_velocity(velocity, max_speed,
	acceleration, delta, move_direction)
	velocity = owner.move_and_slide(velocity, owner.FLOOR_NORMAL)
	
static func calculate_velocity(
		old_velocity: Vector2,
		max_speed: Vector2,
		acceleration: Vector2,
		delta: float,
		move_direction: Vector2
	) -> Vector2:
	var new_velocity = old_velocity
	
	new_velocity += move_direction * acceleration * delta
	new_velocity.x = clamp(new_velocity.x, -max_speed.x, max_speed.x)
	new_velocity.y = clamp(new_velocity.y, -max_speed.y, max_speed.y)
	
	return new_velocity
	
static func get_move_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 1.0
	)


func _on_Enemy_Detector_body_entered(body: Node) -> void:
	if body.is_in_group("Enemies"):
		print_debug("activate")
		_state_machine.transition_to("Move/Damage", {other_body = body})
