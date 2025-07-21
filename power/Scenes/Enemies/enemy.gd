extends CharacterBody3D


const SPEED = 4
const JUMP_VELOCITY = 4.5

var randDirection : Vector3
var HP = 3
var dead : bool = false

var target = null
var attacking : bool = false

func _ready() -> void:
	randDirection = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
	$Target.position = randDirection

func die():
	dead = true
	$Timer.start()
	set_collision_mask_value(2, true)
	set_collision_layer_value(2, true)
	set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	var direction : Vector3 = Vector3.ZERO
	if dead == false:
		if target != null:
			direction = global_position.direction_to(target.global_position)
			$"character-l2".look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))
		else:
			direction = randDirection
			$Target.position = randDirection
			$"character-l2".look_at($Target.global_position)
		if direction != Vector3.ZERO:
			$AnimationTree.set("parameters/ArmsUp/blend_amount", move_toward($AnimationTree.get("parameters/ArmsUp/blend_amount"), 1, delta))
			$AnimationTree.set("parameters/Walking/blend_amount", move_toward($AnimationTree.get("parameters/Walking/blend_amount"), .3, delta))
		else:
			$AnimationTree.set("parameters/ArmsUp/blend_amount", move_toward($AnimationTree.get("parameters/ArmsUp/blend_amount"), 0, delta))
			$AnimationTree.set("parameters/Walking/blend_amount", move_toward($AnimationTree.get("parameters/Walking/blend_amount"), 0, delta))
		if attacking == false and dead == false:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			if target == null:
				velocity.x = direction.x * SPEED/2
				velocity.z = direction.x * SPEED/2
	else:
		velocity.x = 0
		velocity.z = 0
	move_and_slide()

func damage(amount):
	HP -= amount
	if HP <= 0 and dead == false:
		$AnimationTree.set("parameters/Blend2 2/blend_amount", 1)
		$HitBoxBody.set_collision_layer_value(1, false)
		$HitBoxBody.set_collision_mask_value(1, false)
		$HitBoxHead.set_collision_layer_value(1, false)
		$HitBoxHead.set_collision_mask_value(1, false)
		die()

func _on_hit_box_body_area_entered(area: Area3D) -> void:
	if area.name == "Ball":
		damage(1)
		area.queue_free()

func _on_timer_timeout() -> void:
	queue_free()

func _on_hit_box_head_area_entered(area: Area3D) -> void:
	if area.name == "Ball":
		damage(3)
		area.queue_free()

func _on_player_detection_body_entered(body: Node3D) -> void:
	if body.name == "PowerBot":
		target = body

func _on_player_detection_body_exited(body: Node3D) -> void:
	if body.name == "PowerBot":
		target = null

func _on_attack_body_entered(body: Node3D) -> void:
	if body.name == "PowerBot":
		attacking = true
		$"AnimationTree".set("parameters/Attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _on_attack_detect_body_exited(body: Node3D) -> void:
	if body.name == "PowerBot":
		attacking = false

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack-melee-right":
		if $"character-l2/AttackHit".is_colliding():
			if $"character-l2/AttackHit".get_collider().name == "PowerBot":
				$"character-l2/AttackHit".get_collider().damage(1)
		if attacking == true:
			$"AnimationTree".set("parameters/Attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_change_dir_timeout() -> void:
	randDirection = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
