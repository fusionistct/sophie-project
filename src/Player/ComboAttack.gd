extends State

onready var move = get_parent()
var slide_direction : Vector2

func physics_process(delta: float) -> void:
	if !owner.is_on_floor():
		_state_machine.transition_to("Move/Air")
	if owner.attacking == false:
		_state_machine.transition_to("Move/Idle")
	move.physics_process(delta)

func enter(msg: Dictionary = {}) -> void:
	move.attack = true
	owner.attacking = true
	slide_direction = Vector2(1, 0) if owner.sprite.get_scale().x > 0 else Vector2(-1, 0)
	move.velocity = calculate_slide(slide_direction)
	
func exit() -> void:
	move.attack = false
	owner.attacking = false
	return

func calculate_slide(slide_direction, impulse = 0) -> Vector2:
	return move.calculate_velocity(
		Vector2.ZERO,
		Vector2(50,0),
		Vector2(impulse, 0),
		1.0,
		slide_direction,
		false,
		false
	)
