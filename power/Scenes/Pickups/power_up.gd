extends Area3D

var fade : bool = true
var alpha = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fade == true:
		alpha = move_toward(alpha, .8, delta/3)
		$Sprite3D/OmniLight3D.light_energy = move_toward($Sprite3D/OmniLight3D.light_energy, 1, delta * 10)
		if alpha <= .8:
			fade = false
	else:
		alpha = move_toward(alpha, 1, delta/3)
		$Sprite3D/OmniLight3D.light_energy = move_toward($Sprite3D/OmniLight3D.light_energy, 10, delta * 10)
		if alpha >= 1:
			fade = true
	$Sprite3D.set_modulate(Color(1, 1, alpha))


func _on_body_entered(body: Node3D) -> void:
	if body.name == "PowerBot":
		body.powerPointMax += 1
		body.powerPointDisplay()
		visible = false
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		$AudioStreamPlayer3D.play()


func _on_audio_stream_player_3d_finished() -> void:
	queue_free()
