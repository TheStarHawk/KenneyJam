extends Node3D

var GameState : int = 0

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Pause"):
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		$PauseMenu.visible = true

func _on_vaccine_body_entered(body: Node3D) -> void:
	if body.name == "PowerBot":
		GameState += 1
		if GameState == 1:
			$Enemies/Group2.position.y = 0
			$Enemies/Group2.process_mode = Node.PROCESS_MODE_INHERIT
			$Map/Door1.position.y += 1
			$Pickups/EXIT.position.y += 7


func _on_continue_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$PauseMenu.visible = false
	get_tree().paused = false

func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
