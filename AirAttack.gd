extends State

onready var move = get_parent()

func physics_process(delta: float) -> void:
	if owner.is_on_floor():
			_state_machine.transition_to("Move/Idle")
			owner._changeAnim(owner.airAttackAnim, owner.idleAnim)
	if owner.attacking == false:
		if owner.is_on_floor():
			_state_machine.transition_to("Move/Idle")
		else:
			_state_machine.transition_to("Move/Air")
	move.physics_process(delta)

func enter(msg: Dictionary = {}) -> void:
	owner.attacking = true
	#move.attack = true
	
func exit() -> void:
	owner.attacking = false
	#move.attack = false
	return
