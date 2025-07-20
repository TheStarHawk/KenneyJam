extends CharacterBody3D

var target : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_at(target)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = (transform.basis * Vector3.FORWARD).normalized()
	move_and_collide(direction)


func _on_timer_timeout() -> void:
	queue_free()


func _on_ball_body_entered(body: Node3D) -> void:
	if body.name != "PowerBot" or body.name  != "Pew":
		pass
