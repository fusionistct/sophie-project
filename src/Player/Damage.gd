extends State

onready var move = get_parent()

#var knocked_away = false
var knock_back_direction: Vector2 

func physics_process(delta: float) -> void:
	move.physics_process(delta)

func enter(msg: Dictionary = {}) -> void:
	move.enter(msg)
	knock_back_direction = (owner.global_position - msg.other_body.global_position).normalized()
	print_debug(knock_back_direction)
	print_debug(calculate_knock_back(knock_back_direction))
	move.knockback = true
	move.velocity = calculate_knock_back(knock_back_direction)
	print_debug(move.velocity)
	yield(get_tree().create_timer(0.2), "timeout")
	move.knockback = false
	_state_machine.transition_to("Move/Idle")
	

func calculate_knock_back(knock_back_direction) -> Vector2:
	return move.calculate_velocity(
		Vector2.ZERO,
		move.max_speed,
		Vector2(600, 300),
		1.0,
		knock_back_direction
	)
