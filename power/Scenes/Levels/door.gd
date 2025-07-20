extends Node3D

@export var HP : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Number.mesh = load(str("res://Assets/Prototype/number-", HP, ".obj"))
func damage(amount):
	HP -= 1
	$Timer.start()
	if HP <= 0:
		boom()

func boom():
	position.y -= 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_collision_area_entered(area: Area3D) -> void:
	if area.name == "Ball":
		damage(1)


func _on_timer_timeout() -> void:
	HP = 5
