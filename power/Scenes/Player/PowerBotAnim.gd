extends AnimationTree

var movement : float
var aiming : float
var firing
var sprint : bool

var aimingTarget : bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set("parameters/Aiming/blend_amount", aiming)
	set("parameters/Movement/blend_amount", movement)
	set("parameters/WalkRun/blend_position", sprint)
	aiming = move_toward(aiming, aimingTarget, delta * 3)

func _on_timer_timeout() -> void:
	aimingTarget = false
