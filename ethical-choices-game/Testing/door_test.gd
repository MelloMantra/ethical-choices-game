extends AnimatableBody3D

var player : CharacterBody3D
var mainScene : Node3D
@onready var collisionBox : Area3D = $CollisionArea
var playerInBounds : bool = false

@export var message : String = "to open door."

var isOpen : bool = false

var startRotation : float

func _ready():
	mainScene = get_tree().get_root().get_child(0)
	player = mainScene.find_child("Player")
	startRotation = global_rotation.y

func tweenSelf(closing : bool = false):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	if !closing:
		tween.tween_property(self, "global_rotation:y", startRotation + PI/2, .75)
	else:
		tween.tween_property(self, "global_rotation:y", startRotation, .75)
	
func _process(delta):
	if collisionBox.get_overlapping_bodies().find(player) > -1:
		if !playerInBounds:
			playerInBounds = true
			player.call("spawnPrompt", collisionBox.global_position, message, self)
	else:
		if playerInBounds:
			playerInBounds = false
			player.call("removePrompt", self)


func _input(event):
	print(collisionBox.get_overlapping_bodies().find(player))
	if Input.is_action_just_pressed("interact") and collisionBox.get_overlapping_bodies().find(player) > -1:
		
		tweenSelf(!isOpen)
		isOpen = !isOpen
		
