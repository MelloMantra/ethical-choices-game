extends Control




func _on_play_pressed():
	BasicClassFunctions.scene_to_load = "res://Testing/test_world.tscn"
	BasicClassFunctions.newGame()
	

func _on_load_pressed():
	print("data loading")
	BasicClassFunctions.load_data()


func _on_options_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
