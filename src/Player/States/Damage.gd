extends State

onready var move = get_parent()

const KNOCKBACK_TIME = 0.15

#var knocked_away = false
var knock_back_direction: Vector2 

func physics_process(delta: float) -> void:
	move.physics_process(delta)

func enter(msg: Dictionary = {}) -> void:
	move.enter(msg)
	owner.invincible = true
	knock_back_direction = Vector2(1, -.3) if owner.global_position.x - msg.other_body.global_position.x > 0 else Vector2(-1, -.3)
	move.knockback = true
	move.velocity = calculate_knock_back(knock_back_direction)
	yield(get_tree().create_timer(KNOCKBACK_TIME), "timeout")
	move.knockback = false
	_state_machine.transition_to("Move/Idle")

func calculate_knock_back(knock_back_direction) -> Vector2:
	return move.calculate_velocity(
		Vector2.ZERO,
		move.max_speed,
		Vector2(600, 200),
		1.0,
		knock_back_direction,
		false
	)
