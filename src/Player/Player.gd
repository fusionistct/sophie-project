extends KinematicBody2D


onready var state_machine: StateMachine = $StateMachine

onready var collider: CollisionShape2D = $CollisionShape2D
onready var detector: CollisionShape2D = $EnemyDetector/CollisionShape2D
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
onready var hurtAnim = $Sprite/Hurt
onready var deathAnim = $Sprite/Death
onready var groundAttackAnim = $"Sprite/Ground Attack"
onready var airAttackAnim = $"Sprite/Air Attack"

onready var GA1Hitbox = $Hitboxes/GA1Hitbox/CollisionShape2D
onready var GA2Hitbox = $Hitboxes/GA2Hitbox/CollisionShape2D
onready var GA3Hitbox = $Hitboxes/GA3Hitbox/CollisionShape2D
onready var AAHitbox1 = $Hitboxes/AAHitbox/CollisionShape2D
onready var AAHitbox2 = $Hitboxes/AAHitbox/CollisionShape2D2
onready var AAHitbox3 = $Hitboxes/AAHitbox/CollisionShape2D3

onready var currentAnim = idleAnim

onready var health = $Health
onready var dead = false;
onready var attacking = false

#Determines invincibility frames
onready var invincible = false;
var invincibilityTimer
const INVINCIBILITY_TIME = 2

#Determines number of combo attacks left
onready var attackPoints = 3

#Determines whether player is moving left or right (or 0 if neither)
onready var direction = 0

#Measures buffer frames
var jump_buffer_frames_left = 0
var ground_buffer_frames_left = 0

#Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	animationPlayer.connect("animation_finished", self, "_finishTransition")
	invincibilityTimer = Timer.new()
	invincibilityTimer.set_wait_time(INVINCIBILITY_TIME)
	add_child(invincibilityTimer)
	invincibilityTimer.connect("timeout", self, "_finishInvincibility")

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if jump_buffer_frames_left > 0:
		jump_buffer_frames_left -= 1
	
	direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if dead:
		currentAnim.hide()
		deathAnim.show()
		animationPlayer.play("Death")
		yield(animationPlayer, "animation_finished")
		queue_free()
	if invincible and !detector.disabled:
		detector.disabled = true
		sprite.modulate.a = 0.5
		invincibilityTimer.start()
		_changeAnim(currentAnim, hurtAnim)
	if attacking:
		process_attack()
	else:
		process_move()

func process_attack():
	var currentState = state_machine.state
	if currentState.name == "ComboAttack":
		if currentAnim != groundAttackAnim && attackPoints == 3:
			$AttackReset.start()
			_changeAnim(currentAnim, groundAttackAnim)
			attackPoints -= 1
		elif Input.is_action_just_pressed("attack"):
			if attackPoints == 2:
				$AttackReset.start()
				GA1Hitbox.disabled = true
				if sprite.get_scale().x > 0 and direction < 0:
					_handleTurn()
					sprite.set_scale(Vector2(-1, 1))
				elif sprite.get_scale().x < 0 and direction > 0:
					_handleTurn()
					sprite.set_scale(Vector2(1, 1))
				currentState.move.velocity = currentState.calculate_slide(sprite.get_scale(), 100)
				animationPlayer.play("Ground Attack 2")
				attackPoints -= 1
			elif attackPoints == 1:
				$AttackReset.start()
				GA2Hitbox.disabled = true
				if sprite.get_scale().x > 0 and direction < 0:
					_handleTurn()
					sprite.set_scale(Vector2(-1, 1))
				elif sprite.get_scale().x < 0 and direction > 0:
					_handleTurn()
					sprite.set_scale(Vector2(1, 1))
				currentState.move.velocity = currentState.calculate_slide(sprite.get_scale(), 100)
				animationPlayer.play("Ground Attack 3")
				attackPoints = 3
	if state_machine.state.name == "AirAttack":
		if currentAnim != airAttackAnim:
			_changeAnim(currentAnim, airAttackAnim)
			
			

func process_move():
	if direction > 0:
		if sprite.get_scale().x < 0:
			_handleTurn()
		sprite.set_scale(Vector2(1, 1))
		collider.set_scale(Vector2(1, 1))
		_handleMovement()
	elif direction < 0:
		if sprite.get_scale().x > 0:
			_handleTurn()
		sprite.set_scale(Vector2(-1, 1))
		collider.set_scale(Vector2(-1, 1))
		_handleMovement()
	else:
		if animationPlayer.get_current_animation() == "Run":
			_changeAnim(runAnim, runToIdleAnim)
		if animationPlayer.get_current_animation() == "IdleToRun":
			_changeAnim(idleToRunAnim, idleAnim)
		if animationPlayer.get_current_animation() == "TurnAround":
			_changeAnim(turnAroundAnim, runToIdleAnim)
	if not self.is_on_floor():
		var y_velocity = state_machine.state.move.velocity.y #assumes current state is Air
		if currentAnim == hurtAnim:
					yield(animationPlayer, "animation_finished")
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
	GA1Hitbox.position.x = -GA1Hitbox.position.x
	GA2Hitbox.position.x = -GA2Hitbox.position.x
	GA3Hitbox.position.x = -GA3Hitbox.position.x
	AAHitbox1.position.x = -AAHitbox1.position.x
	AAHitbox2.position.x = -AAHitbox2.position.x
	AAHitbox3.position.x = -AAHitbox3.position.x
	collider.position.x *= -1
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
	elif to == hurtAnim:
		animationPlayer.play("Hurt")
	elif to == groundAttackAnim:
		animationPlayer.play("Ground Attack 1")
	elif to == airAttackAnim:
		animationPlayer.play("Air Attack")
	currentAnim = to

func _finishTransition(animName: String) -> void:
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
	elif animName == "Ground Attack 1" or animName == "Ground Attack 2" or animName == "Ground Attack 3":
		attacking = false
		_changeAnim(groundAttackAnim, idleAnim)
	elif animName == "Air Attack":
		_changeAnim(airAttackAnim, idleAnim)
		attacking = false
		
func _finishInvincibility() -> void:
	invincible = false
	detector.disabled = false
	sprite.modulate.a = 1
	invincibilityTimer.stop()
		
func set_is_active(value: bool) -> void:
	is_active = value
	if not collider:
		return
	collider.disabled = not value


func _on_AttackReset_timeout():
	attackPoints = 3
	$AttackReset.stop()
