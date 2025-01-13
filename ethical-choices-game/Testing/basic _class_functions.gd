@tool

extends Node
class_name NodeFunctions


var stopText : bool = false
var textDebounce : bool = false
var currentObject
var defaultPromptSize : int = 10

var playerData = {
	CurrentRoom = Vector2(0,0),
	CurrentHealth = 100,
	CurrentItems = [],
	CurrentAllianceAmount = 0
}


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
	print(panel.size)
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
	print(childList)
	for i in childList.size():
		print(i)
		if childList[i].is_class(classType):
			return {index = i, child = childList[i]}
			
func findItemOfName(searchName : String, list:Array):
	
	
	for i in list.size():
		print(i)
		if list[i].is_class("Node") and list[i].name == searchName:
			return {index = i, child = list[i]}
	return {index = -1, child = null}
