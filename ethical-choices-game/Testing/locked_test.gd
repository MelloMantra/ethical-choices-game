extends AnimatableBody3D

var player : CharacterBody3D
var mainScene : Node3D
@onready var collisionBox1 : Area3D = $Enter1
@onready var collisionBox2 = $Enter2
var playerInBounds : bool = false

@export var message : String = 'Press "E" to unlock door.'
@export var message2 : String = 'Press "E" to open door.'
@export var direction : Vector2 = Vector2.UP

var isOpen : bool = false

var isLocked : bool = true
@export var keyUnlockName : String = "Default Key"

var startRotation : float

func _ready():
	mainScene = BasicClassFunctions.findChildOfClass(get_tree().get_root(), "Node3D").child
	player = mainScene.find_child("Player")
	startRotation = global_rotation.y

func tweenSelf(opening : bool = false):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	if opening:
		tween.tween_property(self, "global_rotation:y", startRotation + PI/2, .75)
	else:
		tween.tween_property(self, "global_rotation:y", startRotation - PI/2, .75)
	
func _process(delta):
	if collisionBox1.get_overlapping_bodies().find(player.currentBody) > -1 or collisionBox2.get_overlapping_bodies().find(player.currentBody) > -1:
		if !playerInBounds:
			playerInBounds = true
			if isLocked:
				BasicClassFunctions.spawnPrompt(message, self)
			else:
				BasicClassFunctions.spawnPrompt(message2, self)
	else:
		if playerInBounds:
			playerInBounds = false
			BasicClassFunctions.removePrompt(self)


func _input(event):
	if !isLocked:
		if Input.is_action_just_pressed("interact") and collisionBox2.get_overlapping_bodies().find(player.currentBody) > -1:
			
			tweenSelf(true)
			mainScene.call("swap_rooms", false, self, direction)
		elif Input.is_action_just_pressed("interact") and collisionBox1.get_overlapping_bodies().find(player.currentBody) > -1:
			tweenSelf(false)
			mainScene.call("swap_rooms", true, self, direction)
	elif BasicClassFunctions.playerData.CurrentItems.find(keyUnlockName) > -1:#BasicClassFunctions.findItemOfName(keyUnlockName, BasicClassFunctions.playerData.CurrentItems).index > -1:
		if Input.is_action_just_pressed("interact") and (collisionBox2.get_overlapping_bodies().find(player.currentBody) > -1 or collisionBox1.get_overlapping_bodies().find(player.currentBody) > -1): 
			isLocked = false
			BasicClassFunctions.removePrompt(self)
			await get_tree().create_timer(.1).timeout
			BasicClassFunctions.spawnPrompt(message2, self)
