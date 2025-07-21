extends Node3D

var GameState : int = 0
var powerPointsCollected : int
var totalZombies : int
var zombiesDefeated : int

func _ready():
	totalZombies = $Enemies/Group1.get_child_count() + $Enemies/Group2.get_child_count()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$PauseMenu.visible = true
		get_tree().paused = true

func _on_vaccine_body_entered(body: Node3D) -> void:
	if body.name == "PowerBot":
		$Enemies/Group2.position.y = 0
		$Enemies/Group2.process_mode = Node.PROCESS_MODE_INHERIT
		$Map/Door1.position.y += 1
		$Pickups/EXIT.position.y += 7


func _on_continue_pressed() -> void:
	$ButtonPress.play()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$PauseMenu.visible = false
	get_tree().paused = false

func _on_exit_pressed() -> void:
	$ButtonPress.play()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")


func _on_restart_pressed():
	$ButtonPress.play()
	get_tree().reload_current_scene()
	
func game_win():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$"GameWin!".visible = true
	$"GameWin!/Stats/PowerGems".text = str("Powergems: ", $Player/PowerBot.powerPointMax, "/10")
	$"GameWin!/Stats/Zombies".text = str("Zombies: ", totalZombies - $Enemies/Group1.get_child_count() + $Enemies/Group2.get_child_count(), "/", totalZombies)
	get_tree().paused = true

func _on_exit_body_entered(body):
	if body.name == "PowerBot":
		game_win()
		
func gameOver():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$GameOver.visible = true
	get_tree().paused = true
