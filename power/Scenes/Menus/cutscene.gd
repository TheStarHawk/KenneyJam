extends Control

var alpha = 1
# Called when the node enters the scene tree for the first time.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if alpha > 0.1:
		alpha -= delta / 45
		set_modulate(Color(1,1,1, alpha))
	else:
		get_tree().change_scene_to_file("res://Scenes/Levels/suburbs_1.tscn")

func _on_skip_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/suburbs_1.tscn")
