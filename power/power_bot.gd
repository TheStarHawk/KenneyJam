extends CharacterBody3D


const SPEED = 6
const JUMP_VELOCITY = 4.5

var healthPoints : int = 3
var healthPointMax : int = 3
var powerPoints : int = 0
@export var powerPointMax : int = 5
var rechargeRate : int
var dead : bool = false
var walking : bool = false

#CameraVariables
var mouseInput
var hInput : float
var yInput : float
var mouseRotation : Vector3
var mouseSensitivity : float = .5
var cameraUpLimit = deg_to_rad(-45)
var cameraDownLimit = deg_to_rad(45)
var CamPos = -1.5
var leftSide : bool = true

#movementVariables
var input_dir
var direction : Vector3

#AnimationVariables
@onready var anim = $AnimationTree

func heal(amount):
	if powerPointMax >= 3:
		if powerPoints >= 3:
			healthPoints = clampi(healthPoints + amount, 0, healthPointMax)
			powerPoints -= 3
			$Heal.emitting = true
			$Sounds/Heal.play()
			healthPointDisplay()
			powerPointDisplay()
			$Recharge.start()
		else:
			$Sounds/Fizzle.play()

func damage(amount):
	if healthPoints >= 1:
		healthPoints -= amount
		healthPointDisplay()
		$Hurt.emitting = true
		$Sounds/Damage.play()
	if healthPoints == 0:
		gameOver()

func gameOver():
	$AnimationTree.set("parameters/Die/blend_amount", 1)
	dead = true
	velocity = Vector3.ZERO

func fire() -> void:
	if powerPointMax >= 1:
		if powerPoints >= 1:
			var pew = load("res://Scenes/Player/pew.tscn").instantiate()
			pew.global_transform = $ProjectileStart.global_transform
			pew.target = $"character-g2/character-g/root/torso/head2/TargetReset".global_position
			pew.target = $"character-g2/character-g/root/torso/head2/TargetReset".global_position
			add_sibling(pew)
			$Sounds/Pew.play()
			$Recharge.start()
			powerPoints -= 1
			powerPointDisplay()
		else:
			$Sounds/Fizzle.play()

func _ready() -> void:
	healthPointDisplay()
	powerPointDisplay()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		$Sounds/Footsteps.stop()
		walking = false

	if dead == false:
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		input_dir = Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			if walking == false and is_on_floor():
				$Sounds/Footsteps.play()
				walking = true
		else:
			if walking == true:
				$Sounds/Footsteps.stop()
				walking = false
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			$AnimationTree.movement = false
			
		if Input.is_action_just_released("fireWeapon"):
			fire()
		if Input.is_action_just_pressed("heal"):
			heal(1)
		handleAiming()
		cameraControl(delta)
	else:
		velocity = Vector3.ZERO
	animationControl(delta)
	move_and_slide()

func handleAiming():
	if $"character-g2/character-g/root/torso/head2/RayCast3D".is_colliding():
		$"character-g2/character-g/root/torso/head2/TargetReset".global_position = $"character-g2/character-g/root/torso/head2/RayCast3D".get_collision_point()
		$"character-g2/character-g/root/torso/head2/TargetReset".position.z -= 1
	else:
		$"character-g2/character-g/root/torso/head2/TargetReset".position = Vector3(0, 0.4, 30)
	
func animationControl(delta):
	if is_on_floor():
		if direction:
			anim.movement = .7
		else:
			anim.movement = 0
	if Input.is_action_just_pressed("fireWeapon") and powerPointMax >= 1:
		anim.set("parameters/Fire/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		anim.aimingTarget = 1
		$AnimationTree/Timer.start()
	$"character-g2/character-g/root/torso/head2".rotation.x = -$CameraController.rotation.x

func _unhandled_input(event: InputEvent) -> void:
	mouseInput = event is InputEventMouseMotion
	if mouseInput:
		hInput = -event.relative.x * mouseSensitivity
		yInput = -event.relative.y * mouseSensitivity

func cameraControl(delta):
	mouseRotation.x += yInput * delta
	mouseRotation.x = clamp(mouseRotation.x, cameraUpLimit, cameraDownLimit)
	mouseRotation.y += hInput * delta
	rotation.y = mouseRotation.y
	$CameraController.rotation.x = mouseRotation.x
	yInput = 0
	hInput = 0
	if Input.is_action_just_pressed("cameraSwap"):
		if leftSide == true:
			CamPos = 1.5
			leftSide = false
		else:
			CamPos = -1.5
			leftSide = true
	if $CameraController.position.x != CamPos:
		$CameraController.position.x = move_toward($CameraController.position.x, CamPos, delta * 5)

func _on_recharge_timeout() -> void:
	if dead == false:
		powerPoints = clampi(powerPoints + 1, 0, powerPointMax)
		powerPointDisplay()

func healthPointDisplay():
	while $Control/HealthPointDisplay.get_child_count() < healthPointMax:
		var HP = load("res://Scenes/Player/health_point.tscn").instantiate()
		HP.name = str($Control/HealthPointDisplay.get_child_count())
		$Control/HealthPointDisplay.add_child(HP)
	var currentPoints = 0
	var totalPoints =  healthPointMax
	while currentPoints < totalPoints:
		if currentPoints <= healthPoints - 1:
			var bright = $Control/HealthPointDisplay.get_child(currentPoints)
			bright.set_modulate(Color(1,1,1,1))
			currentPoints += 1
		if totalPoints > healthPoints:
			var dim = $Control/HealthPointDisplay.get_child(totalPoints - 1)
			dim.set_modulate(Color(.5,.5,.5,.5))
			totalPoints -=1

func powerPointDisplay():
	while $Control/PowerPointDisplay.get_child_count() < powerPointMax:
		var PP = load("res://Scenes/Player/power_point.tscn").instantiate()
		PP.name = str($Control/PowerPointDisplay.get_child_count())
		$Control/PowerPointDisplay.add_child(PP)
		print("haha pp")
	var currentPoints = 0
	var totalPoints =  powerPointMax
	while currentPoints < totalPoints:
		if currentPoints <= powerPoints - 1:
			var bright = $Control/PowerPointDisplay.get_child(currentPoints)
			bright.set_modulate(Color(1,1,1,1))
			currentPoints += 1
		if totalPoints > powerPoints:
			var dim = $Control/PowerPointDisplay.get_child(totalPoints - 1)
			dim.set_modulate(Color(.5,.5,.5,.5))
			totalPoints -=1

func _on_footsteps_finished() -> void:
	$Sounds/Footsteps.pitch_scale = randf_range(.6, .9)
	$Sounds/Footsteps/Timer.start()

func _on_timer_timeout() -> void:
	if walking == true:
		$Sounds/Footsteps.play()
