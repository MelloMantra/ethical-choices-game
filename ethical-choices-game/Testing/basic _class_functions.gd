@tool

extends Node
class_name NodeFunctions


var stopText : bool = false
var textDebounce : bool = false
var currentObject
var defaultPromptSize : int = 10

var playerData = {
	CurrentRoom = Vector2(0,0),
	LastEnteredPos = Vector3(0,0,0),
	CurrentHealth = 100,
	CurrentItems = [],
	CurrentAllianceAmount = 0
}
var scene_to_load : String = "res://Testing/test_world.tscn"
var isNewGame : bool = false
func newGame():
	playerData = {
		CurrentRoom = Vector2(0,0),
		LastEnteredPos = Vector3(0,0,0),
		CurrentHealth = 100,
		CurrentItems = [],
		CurrentAllianceAmount = 0
	}
	isNewGame = true
	load_data()


func save_data():
	var currentSceneChildren : Array[String] = []
	for child in findChildOfClass(get_tree().get_root(), "Node3D").child.get_children():
		currentSceneChildren.append(child.name)
		
	var saveDict : Dictionary = {
		pData = playerData,
		currentScene = findChildOfClass(get_tree().get_root(), "Node3D").child.scene_file_path,
		currentLoadedChildren = currentSceneChildren
	}
	
	var file : FileAccess = FileAccess.open("user://UlyssesSavedData", FileAccess.WRITE)
	file.store_string(JSON.stringify(saveDict))
	
	file.close()
var loadDict : Dictionary
func load_data():
	if FileAccess.file_exists("user://UlyssesSavedData") and !isNewGame:
		var json : JSON = JSON.new()
		json.parse(FileAccess.open("user://UlyssesSavedData", FileAccess.READ).get_as_text())
		loadDict = json.data
		print("this is the loadDict",loadDict)
		print(loadDict.pData)
		
		playerData = loadDict.pData
		playerData.CurrentRoom = string_to_vector2(playerData.CurrentRoom)
		playerData.LastEnteredPos = string_to_vector3(playerData.LastEnteredPos)
		
		scene_to_load = loadDict.currentScene
	else:
		scene_to_load = "res://Testing/test_world.tscn"
	get_tree().change_scene_to_file("res://Testing/load_screen.tscn")
	isNewGame = false

func _check_scene_contents():
	if loadDict:
		var mainScene : Node3D = findChildOfClass(get_tree().get_root(), "Node3D").child
		var childArray : Array = mainScene.get_children()
		print(loadDict.currentLoadedChildren)
		for index in childArray.size():
			print(childArray[index])
			if loadDict.currentLoadedChildren.find(childArray[index].name) < 0:
				
				childArray[index].queue_free()
		

func dispText(text : String, label : Label, panel : PanelContainer):
	
	var string = ""
	label.text = string
	stopText = false
	textDebounce = true
	for i in text.length():
		string += text.substr(i,1)
		label.text = string
		label.remove_theme_font_size_override("font_size")
		update_font_size(label)
		await get_tree().create_timer(.01, false).timeout
		if stopText:
			break
	
	textDebounce = false

func spawnPrompt(newTxt : String, object = null,
	promptBox : Label = get_node("/root/TestWorld/Player/GameUI/PromptPanel/HBoxContainer/Label"),
	promptPanel : PanelContainer = get_node("/root/TestWorld/Player/GameUI/PromptPanel")):
	promptBox.text = ""
	if !textDebounce or object != currentObject:
		promptPanel.visible = true
		stopText = true
		await get_tree().create_timer(.075, false).timeout
		
		dispText(newTxt, promptBox, promptPanel)
		currentObject = object

func removePrompt(object, promptPanel : PanelContainer = get_node("/root/TestWorld/Player/GameUI/PromptPanel")):
	promptPanel.visible = false
	stopText = true
	if object == currentObject:
		currentObject = null

func update_font_size(label : Label):
	var font_size = label.get_theme_font_size("font_size")
	
	while label.get_visible_line_count() < label.get_line_count():
		font_size -= 1
		
		label.add_theme_font_size_override("font_size", font_size)

func findChildOfClass(object : Node, classType : String):
	var childList : Array[Node] = object.get_children()
	
	for i in childList.size():
		
		if childList[i].is_class(classType):
			return {index = i, child = childList[i]}
			
func findItemOfName(searchName : String, list:Array):
	
	
	for i in list.size():
		
		if list[i].is_class("Node") and list[i].name == searchName:
			return {index = i, child = list[i]}
	return {index = -1, child = null}

static func string_to_vector2(string := "") -> Vector2:
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")

		return Vector2(float(array[0]), float(array[1]))

	return Vector2.ZERO
static func string_to_vector3(string := "") -> Vector3:
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")

		return Vector3(float(array[0]), float(array[1]), float(array[2]))

	return Vector3.ZERO
