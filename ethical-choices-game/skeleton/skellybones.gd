extends CharacterBody3D

@onready var mainScene : Node3D = BasicClassFunctions.findChildOfClass(get_tree().get_root(), "Node3D").child
@onready var player : CharacterBody3D = mainScene.get_node("Player")
@onready var navAgent : NavigationAgent3D = $NavigationAgent3D

var isVisible : bool = false
const SPEED : float = 4.0

func _on_visible_on_screen_notifier_3d_screen_entered():
	isVisible = true
func _on_visible_on_screen_notifier_3d_screen_exited():
	isVisible = false

var playerPos : Vector3 = Vector3.ZERO
var isKnockback : bool = false
var currentKnockbackFrames : int = 0

@export var currentRoom : Vector2 = Vector2.ZERO
@export var enemyHealth : float = 30.0
@export var knockbackFrames: int = 30
@export var attackRadius : float = 5.0
@export var attackFrequency : float = 6.0 # seconds
@export var timeSinceShot : float = 0.0
@export var state = "useable" # can also be "flying" or "timeout"

var currentHealth := enemyHealth


func _physics_process(delta):
	if playerPos.distance_to(player.global_position) > .5:
		playerPos = player.global_position
		navAgent.target_position = playerPos
	
	if global_position.z > player.global_position.z:
		$Sprite3D.render_priority = 3
	else:
		$Sprite3D.render_priority = 0
	
	if isVisible and currentRoom == BasicClassFunctions.playerData.CurrentRoom and player.currentPlayerState != player.playerStates.TRANSITION:
		var direction := navAgent.get_next_path_position() - global_position
		if isKnockback:
			if currentKnockbackFrames >= knockbackFrames:
				isKnockback = false
				currentKnockbackFrames = 0
			currentKnockbackFrames += 1
			direction = global_position - player.global_position
		if (global_position - player.global_position).length()<attackRadius and !isKnockback:
			direction = Vector3.ZERO
			velocity = Vector3.ZERO
			timeSinceShot += delta
			if timeSinceShot>=attackFrequency:
				attack()
				timeSinceShot = 0
		else:
			direction = direction.normalized()
		
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		move_and_slide()

func takeDamage(damage : float):
	isKnockback = true
	currentHealth -= damage
	if currentHealth <= 0:
		queue_free()


func attack():
	var boneProj = load("res://skeleton/bone.tscn")
	boneProj = boneProj.instantiate()
	mainScene.add_child(boneProj)
	boneProj.global_position = global_position + Vector3(0,0.5,0)
	boneProj.direction = (player.global_position - boneProj.global_position).normalized()
