extends Control

func _ready():
		$VBoxContainer/Resume.connect("pressed", resumeGame)
		$VBoxContainer/Quit.connect("pressed", gameQuit)


func gameQuit():
	get_tree().quit()

func resumeGame():
	get_tree().paused = false
	visible = false

func _input(event):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			visible = true
		else:
			visible = false
