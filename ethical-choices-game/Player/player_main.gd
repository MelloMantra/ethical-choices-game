extends CharacterBody3D


const SPEED = 4
const accel = 8 #accel amount / sec

var currentHealth : float = 100.0

@onready var currentBody : CharacterBody3D = self

@onready var camera = $Camera3D
@onready var sprite : AnimatedSprite3D = $SpriteTest
@onready var slash : AnimatedSprite3D = $AttackCollider/TestSlash
@onready var attackArea : Area3D = $AttackCollider

@onready var promptBox : Label = $GameUI/PromptPanel/HBoxContainer/Label
@onready var promptPanel : PanelContainer = $GameUI/PromptPanel
@onready var fader = $GameUI/Panel

enum playerStates {
	NORMAL,
	ATTACKING,
	TRANSITION
}
var currentPlayerState : playerStates = playerStates.NORMAL

signal transitionComplete
var transitionTime : float = 0.0
@export var roomTransitionLength : float = 1

func _ready():
	BasicClassFunctions.defaultPromptSize = promptPanel.size.y
	print(promptPanel.size.y)
	sprite.play("Idle")
	currentHealth = BasicClassFunctions.playerData.CurrentHealth
	$GameUI/Health.value = currentHealth
	global_position = BasicClassFunctions.playerData.LastEnteredPos
	BasicClassFunctions.save_data()

var zDepth

func _physics_process(delta):
	
	if currentPlayerState == playerStates.TRANSITION:
		
		if currentBody.velocity.length() > 0:
			transitionTime += delta
			
			if transitionTime >= roomTransitionLength:
				emit_signal("transitionComplete")
				transitionTime = 0.0
		else:
			emit_signal("transitionComplete")
			transitionTime = 0.0
		currentBody.move_and_slide()
		return
	if $Camera3D/DistanceRay.is_colliding():
		zDepth = $Camera3D/DistanceRay.get_collision_point()
		zDepth = zDepth.distance_to(camera.global_position)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("walkL", "walkR", "walkF", "walkB")
	var camDirection : Transform3D = camera.global_transform
	camDirection.basis.z = camDirection.basis.x.cross(Vector3.UP)
	camDirection.basis.y = Vector3.UP
	var direction = (camDirection.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and currentPlayerState != playerStates.TRANSITION:
		currentBody.velocity.x = min(abs(direction.x * SPEED), abs(velocity.x + direction.x * accel * delta)) * sign(direction.x)
		currentBody.velocity.z = min(abs(direction.z * SPEED), abs(velocity.z + direction.z * accel * delta)) * sign(direction.z)
	elif currentPlayerState != playerStates.TRANSITION:
		currentBody.velocity.x = move_toward(velocity.x, 0, SPEED)
		currentBody.velocity.z = move_toward(velocity.z, 0, SPEED)
	if Input.is_action_pressed("sprint"):
		currentBody.velocity *= Vector3(1.5,1,1.5)
	
	
	
	if currentPlayerState == playerStates.NORMAL:
		if currentBody.velocity.length() != 0:
			if velocity.x != 0:
				sprite.flip_h = velocity.x < 0
			if currentBody.velocity.z > 0:
				slash.render_priority = 4
			else:
				slash.render_priority = 1
			if currentBody.velocity.length() <= SPEED:
				sprite.play("Walk")
			else:
				sprite.play("Sprint")
		else:
			sprite.play("Idle")
	elif currentPlayerState != playerStates.TRANSITION:
		currentBody.velocity.x = move_toward(velocity.x, 0, SPEED)
		currentBody.velocity.z = move_toward(velocity.z, 0, SPEED)
		

	currentBody.move_and_slide()


func _input(event):
	
	if Input.is_action_just_pressed("basic_attack") and currentPlayerState == playerStates.NORMAL:
		currentPlayerState = playerStates.ATTACKING
		slash.play("slash")
		for hit in attackArea.get_overlapping_bodies():
			if hit.has_method("takeDamage"):
				hit.call("takeDamage", 15)
		await slash.animation_finished
		currentPlayerState = playerStates.NORMAL
	elif event is InputEventMouseMotion and zDepth:
		var lookPoint : Vector3 = camera.project_position(event.position, zDepth)
		lookPoint.y = attackArea.global_position.y
		attackArea.look_at(lookPoint)

func takeDamage(damage : float, pos : Vector3):
	currentHealth -= damage
	BasicClassFunctions.playerData.CurrentHealth = currentHealth
	var temp = roomTransitionLength
	roomTransitionLength = .5
	currentPlayerState = playerStates.TRANSITION
	velocity = (global_position - pos).normalized() * SPEED
	sprite.play("Knockback")
	
	await transitionComplete
	create_tween().tween_property($GameUI/Health, "value", currentHealth, .5)
	roomTransitionLength = temp
	currentPlayerState = playerStates.NORMAL
	if currentHealth <= 0:
		
		BasicClassFunctions.load_data()

func swap_bodies():
	var tween : Tween = create_tween()
	await tween.tween_property(fader["theme_override_styles/panel"], "bg_color", Color("000000"), .25).finished
	tween.tween_property(fader["theme_override_styles/panel"], "bg_color", Color("00000000"), .25)


func _on_attack_collider_body_entered(body):
	if currentPlayerState == playerStates.ATTACKING and body.has_method("takeDamage"):
		body.call("takeDamage", 15)
