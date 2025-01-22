extends StaticBody3D

var mouseHover : bool = false
@export var visible_name : String = "Default Key"
@onready var mainScene : Node3D = BasicClassFunctions.findChildOfClass(get_tree().get_root(), "Node3D").child
@onready var player : CharacterBody3D = BasicClassFunctions.findChildOfClass(mainScene, "CharacterBody3D").child

func _ready():
	connect("mouse_entered", mouse_hover)
	connect("mouse_exited", mouse_unhover)

var showingMsg : bool = false

func mouse_hover():
	mouseHover = true
	print("mouse hovered ", global_position.distance_to(player.currentBody.global_position))
	if global_position.distance_to(player.currentBody.global_position) < 2:
		BasicClassFunctions.spawnPrompt(str('Press "E" to pick up', visible_name), self)
		showingMsg = true
func mouse_unhover():
	mouseHover = false
	showingMsg = false
	BasicClassFunctions.removePrompt(self)
	

func _process(delta):
	if global_position.distance_to(player.currentBody.global_position) > 2 and mouseHover and showingMsg:
		BasicClassFunctions.removePrompt(self)
		showingMsg = false
	if global_position.distance_to(player.currentBody.global_position) < 2 and mouseHover and !showingMsg:
		BasicClassFunctions.spawnPrompt(str('Press "E" to pick up', visible_name), self)
		showingMsg = true

func _input(event):
	if Input.is_action_just_pressed("interact") and showingMsg:
		BasicClassFunctions.playerData.CurrentItems.append(visible_name)
		
		BasicClassFunctions.removePrompt(self)
		queue_free()
