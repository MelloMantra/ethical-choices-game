extends Node3D

@onready var player = $Player
@onready var camera = $Player/Camera3D

@export var cameraMarkers : Array[Array] = [[],[]]

func _ready():
	BasicClassFunctions._check_scene_contents()
	var currentRoom = BasicClassFunctions.playerData.CurrentRoom
	camera.global_position = get_node(cameraMarkers[currentRoom.x][currentRoom.y]).global_position
	get_node(cameraMarkers[currentRoom.x][currentRoom.y]).get_node("FogVolume").material.density = 0

func swap_rooms(isReverse : bool, door : AnimatableBody3D, direction : Vector2):
	var currentRoom = BasicClassFunctions.playerData.CurrentRoom
	var doorPos : Vector3 = door.get_node("Enter1").global_position
	if isReverse:
		doorPos = door.get_node("Enter2").global_position
		direction *= -1
	doorPos.y = player.currentBody.global_position.y
	player.currentPlayerState = player.playerStates.TRANSITION
	await get_tree().create_timer(.1).timeout
	player.currentBody.velocity = (doorPos- player.currentBody.global_position)/player.roomTransitionLength
	player.get_node("SpriteTest").no_depth_test = false
	BasicClassFunctions.playerData.LastEnteredPos = doorPos
	player.currentBody.set_collision_mask_value(3, false)
	await player.transitionComplete
	player.currentBody.velocity = Vector3.ZERO
	player.currentBody.global_position = doorPos
	var tween : Tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(door, "rotation:y", door.startRotation, .75)
	var lastCamPos = BasicClassFunctions.findChildOfClass(get_node(cameraMarkers[currentRoom.x][currentRoom.y]), "FogVolume").child
	currentRoom += direction
	var fogTween :Tween = get_tree().create_tween()
	var camPos = BasicClassFunctions.findChildOfClass(get_node(cameraMarkers[currentRoom.x][currentRoom.y]), "FogVolume").child

	fogTween.tween_property(camPos.material, "density", 0, .75)
	tween.set_trans(Tween.TRANS_SINE)

	await tween.tween_property(camera, "global_position", get_node(cameraMarkers[currentRoom.x][currentRoom.y]).global_position, .75).finished
	fogTween = get_tree().create_tween()
	fogTween.tween_property(lastCamPos.material, "density", 2.5, .75)
	player.currentPlayerState = player.playerStates.NORMAL
	player.currentBody.set_collision_mask_value(3, true)
	player.get_node("SpriteTest").no_depth_test = true
	BasicClassFunctions.playerData.CurrentRoom = currentRoom
	
