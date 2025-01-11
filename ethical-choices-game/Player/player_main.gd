extends CharacterBody3D


const SPEED = 4
const accel = 8 #accel amount / sec

@onready var camera = $Camera3D


@onready var promptBox : Label = $GameUI/PromptPanel/HBoxContainer/Label
@onready var promptPanel : PanelContainer = $GameUI/PromptPanel
var currentObject
var stopText : bool = false
var textDebounce : bool = false

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

func spawnPrompt( newTxt : String, object = null):
	if !textDebounce or object != currentObject:
		promptPanel.visible = true
		stopText = true
		await get_tree().create_timer(.075, false)
		
		dispText(newTxt, promptBox)
		currentObject = object

func removePrompt(object):
	promptPanel.visible = false
	stopText = true
	if object == currentObject:
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
