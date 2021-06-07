extends State

onready var move = get_parent()
var jumpCancelled = false

func physics_process(delta: float) -> void:
	
	owner.jumpFrame += 1
	
	if owner.jumpFrame < 10:
		if Input.is_action_just_released("jump"):
			jumpCancelled = true
	
	if owner.jumpFrame == 10 and jumpCancelled: 
		move.velocity.y = 0
		jumpCancelled = false
		
	if owner.jumpFrame >= 10:
		if Input.is_action_just_released("jump") and move.velocity.y < 0:
			move.velocity.y = 0
	
	if owner.is_on_floor():
			owner.jumpFrame = 0
			move.velocity.x = 0
			if Input.is_action_just_pressed("attack"):
				_state_machine.transition_to("Move/ComboAttack")
			#owner._changeAnim(owner.airAttackAnim, owner.idleAnim)
			#_state_machine.transition_to("Move/Idle")
			move.attack = true
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
	move.attack = false
	return
