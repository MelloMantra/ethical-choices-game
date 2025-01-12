extends CharacterBody3D


const SPEED = 4
const accel = 8 #accel amount / sec

@onready var camera = $Camera3D
var interactPrompt = preload("res://Testing/prompt.tscn")

var currentPrompt : MeshInstance3D
var currentObject

func spawnPrompt(newPos : Vector3, newTxt : String, object = null):
	if currentPrompt:
		currentPrompt.queue_free()
		currentPrompt = null
	var newPrompt = interactPrompt.instantiate()
	get_tree().get_root().get_child(0).add_child(newPrompt)
	newPrompt.global_position = newPos
	newPrompt.get_node("SubViewport/InteractPrompt/Panel/VBoxContainer/Action").text = newTxt
	currentPrompt = newPrompt
	currentObject = object

func removePrompt(object):
	if currentPrompt and object == currentObject:
		currentPrompt.queue_free()
		currentPrompt = null
		currentObject = null

func _physics_process(delta):
	
	

	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("walkL", "walkR", "walkF", "walkB")
	var camDirection : Transform3D = camera.global_transform
	camDirection.basis.z = camDirection.basis.x.cross(Vector3.UP)
	camDirection.basis.y = Vector3.UP
	var direction = (camDirection.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = min(abs(direction.x * SPEED), abs(velocity.x + direction.x * accel * delta)) * sign(direction.x)
		velocity.z = min(abs(direction.z * SPEED), abs(velocity.z + direction.z * accel * delta)) * sign(direction.z)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
