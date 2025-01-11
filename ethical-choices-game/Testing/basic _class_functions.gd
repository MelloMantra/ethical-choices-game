@tool

extends Node
class_name NodeFunctions


var stopText : bool = false
var textDebounce : bool = false
var currentObject

func dispText(text : String, label : Label):
	var string = ""
	label.text = string
	stopText = false
	textDebounce = true
	for i in text.length() - 1:
		string += text.substr(i,1)
		label.text = string
		await get_tree().create_timer(.01, false).timeout
		if stopText:
			break
	textDebounce = false

func spawnPrompt(newTxt : String, object = null,
	promptBox : Label = get_node("/root/TestWorld/Player/GameUI/PanelContainer/HBoxContainer/Label"),
	promptPanel : PanelContainer = get_node("/root/TestWorld/Player/GameUI/PanelContainer")):
	
	if !textDebounce or object != currentObject:
		promptPanel.visible = true
		stopText = true
		await get_tree().create_timer(.075, false)
		
		dispText(newTxt, promptBox)
		currentObject = object

func removePrompt(object, promptPanel : PanelContainer = get_node("/root/TestWorld/Player/GameUI/PanelContainer")):
	promptPanel.visible = false
	stopText = true
	if object == currentObject:
		currentObject = null
