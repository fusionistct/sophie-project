extends KinematicBody2D


onready var state_machine: StateMachine = $StateMachine

onready var collider: CollisionShape2D = $CollisionShape2D
onready var sprite: Node2D = $Sprite

const FLOOR_NORMAL = Vector2.UP

var is_active = true setget set_is_active

onready var animationPlayer = $AnimationPlayer
onready var idleAnim = $Sprite/Idle
onready var runAnim = $Sprite/Run;
onready var idleToRunAnim = $Sprite/IdleToRun
onready var runToIdleAnim = $Sprite/RunToIdle
onready var turnAroundAnim = $Sprite/TurnAround
onready var jumpAnim = $Sprite/Jump
onready var fallAnim = $Sprite/Fall
onready var jumpToFallAnim = $Sprite/JumpToFall
onready var landingAnim = $Sprite/Landing

onready var currentAnim = idleAnim

onready var lastAnim = idleAnim

#Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	animationPlayer.connect("animation_finished", self, "finishTransition")

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if currentAnim != lastAnim:
		print_debug(currentAnim.name)
		lastAnim = currentAnim
	var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if direction > 0:
		if sprite.get_scale().x < 0:
			_handleTurn()
		sprite.set_scale(Vector2(1, 1))
		_handleMovement()
	elif direction < 0:
		if sprite.get_scale().x > 0:
			_handleTurn()
		sprite.set_scale(Vector2(-1, 1))
		_handleMovement()
	else:
		if animationPlayer.get_current_animation() == "Run":
			_changeAnim(runAnim, runToIdleAnim)
		if animationPlayer.get_current_animation() == "IdleToRun":
			_changeAnim(idleToRunAnim, idleAnim)
	if not self.is_on_floor():
		var y_velocity = state_machine.state.move.velocity.y #assumes current state is Air
		if y_velocity >= 0:
			if currentAnim == jumpAnim:
				_changeAnim(currentAnim, jumpToFallAnim)
			elif currentAnim != fallAnim and currentAnim != jumpToFallAnim:
				_changeAnim(currentAnim, fallAnim)
		if y_velocity < 0:
			if currentAnim != jumpAnim:
				_changeAnim(currentAnim, jumpAnim) 
	else:
		if animationPlayer.get_current_animation() == "Jump" or animationPlayer.get_current_animation() == "Fall" or animationPlayer.get_current_animation() == "JumpToFall":
			if direction == 0:
				_changeAnim(currentAnim, landingAnim)
			else: 
				_handleMovement()

func _handleTurn() -> void:
	if self.is_on_floor():
		if animationPlayer.get_current_animation() == "Run" || animationPlayer.get_current_animation() == "RunToIdle":
			_changeAnim(currentAnim, turnAroundAnim)
			

func _handleMovement() -> void:
	if self.is_on_floor():
		if currentAnim == landingAnim:
			_changeAnim(currentAnim, idleToRunAnim)
		elif currentAnim == jumpAnim or currentAnim == fallAnim or currentAnim == jumpToFallAnim:
			_changeAnim(currentAnim, idleToRunAnim)
		elif animationPlayer.get_current_animation() == "RunToIdle":
			_changeAnim(runToIdleAnim, runAnim)
		elif animationPlayer.get_current_animation() == "Idle":
			_changeAnim(idleAnim,idleToRunAnim)
#		elif currentAnim == idleToRunAnim:
#			yield (animationPlayer, "animation_finished")
#			_changeAnim(idleToRunAnim, runAnim)
	
func _changeAnim(from: Sprite, to: Sprite) -> void:
	animationPlayer.seek(0, true)
	from.hide()
	to.show()
	if to == runAnim:
		animationPlayer.play("Run")
	elif to == idleAnim:
		animationPlayer.play("Idle")
	elif to == idleToRunAnim:
		animationPlayer.play("IdleToRun")
	elif to == runToIdleAnim:
		animationPlayer.play("RunToIdle")
	elif to == turnAroundAnim:
		animationPlayer.play("TurnAround")
		if sprite.get_scale().x > 0:
			sprite.set_scale(Vector2(-1, 1))
		elif sprite.get_scale().x < 0:
			sprite.set_scale(Vector2(1, 1))
	elif to == jumpAnim:
		animationPlayer.play("Jump")
	elif to == fallAnim:
		animationPlayer.play("Fall")
	elif to == jumpToFallAnim:
		animationPlayer.play("JumpToFall")
	elif to == landingAnim:
		animationPlayer.play("Landing")
	currentAnim = to

func finishTransition(animName: String) -> void:
	if animName == "RunToIdle":
		_changeAnim(runToIdleAnim, idleAnim)
	elif animName == "JumpToFall":
		_changeAnim(jumpToFallAnim, fallAnim)
	elif animName == "Landing":
		_changeAnim(landingAnim, idleAnim)
	elif animName == "IdleToRun":
		_changeAnim(idleToRunAnim, runAnim)
	elif animName == "TurnAround":
		_changeAnim(turnAroundAnim, runAnim)
		
func set_is_active(value: bool) -> void:
	is_active = value
	if not collider:
		return
	collider.disabled = not value
