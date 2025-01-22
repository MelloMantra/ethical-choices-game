extends AnimatableBody3D

var player : CharacterBody3D
var mainScene : Node3D
@onready var collisionBox1 : Area3D = $Enter1
@onready var collisionBox2 = $Enter2
var playerInBounds : bool = false

@export var message : String = 'Press "E" to open door.'
@export var direction : Vector2 = Vector2.UP

var isOpen : bool = false

var startRotation : float

var debounce : bool = false

func _ready():
	mainScene = BasicClassFunctions.findChildOfClass(get_tree().get_root(), "Node3D").child
	player = mainScene.find_child("Player")
	startRotation = global_rotation.y

func tweenSelf(opening : bool = false):
	if !debounce:
		debounce = true
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BOUNCE)
		if opening:
			tween.tween_property(self, "global_rotation:y", startRotation + PI/2, .75)
		else:
			tween.tween_property(self, "global_rotation:y", startRotation - PI/2, .75)
		await tween.finished
		debounce = false
	
func _process(delta):
	if collisionBox1.get_overlapping_bodies().find(player.currentBody) > -1 or collisionBox2.get_overlapping_bodies().find(player.currentBody) > -1:
		if !playerInBounds:
			playerInBounds = true
			BasicClassFunctions.spawnPrompt(message, self)
	else:
		if playerInBounds:
			playerInBounds = false
			BasicClassFunctions.removePrompt(self)


func _input(event):
	#print(collisionBox.get_overlapping_bodies().find(player))
	if !debounce:
		if Input.is_action_just_pressed("interact") and collisionBox2.get_overlapping_bodies().find(player.currentBody) > -1:
			
			tweenSelf(true)
			mainScene.call("swap_rooms", false, self, direction)
		elif Input.is_action_just_pressed("interact") and collisionBox1.get_overlapping_bodies().find(player.currentBody) > -1:
			tweenSelf(false)
			mainScene.call("swap_rooms", true, self, direction)
