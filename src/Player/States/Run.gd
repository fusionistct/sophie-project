extends State

onready var move = get_parent()

func unhandled_input(event: InputEvent) -> void:
	move.unhandled_input(event)

func physics_process(delta: float) -> void:
	if owner.is_on_floor():
		if move.get_move_direction().x == 0.0:
			_state_machine.transition_to("Move/Idle")
	else:
		_state_machine.transition_to("Move/Air")
		owner.ground_buffer_frames_left = 5
	move.physics_process(delta)

func enter(msg: Dictionary = {}) -> void:
	move.enter(msg)

func exit() -> void:
	return
