extends Control

func _ready():
		$VBoxContainer/Resume.connect("pressed", resumeGame)
		$VBoxContainer/Quit.connect("pressed", gameQuit)


func gameQuit():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func resumeGame():
	get_tree().paused = false
	visible = false
	BasicClassFunctions.save_data()

func _input(event):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			visible = true
		else:
			visible = false
