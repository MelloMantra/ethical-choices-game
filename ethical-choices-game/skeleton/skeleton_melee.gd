extends CharacterBody3D

@export var currentRoom : Vector2 = Vector2.ZERO
@export var enemyHealth : float = 30.0
@export var knockbackFrames: int = 30

@onready var navAgent : NavigationAgent3D = $NavigationAgent3D
@onready var hitArea : Area3D = $HitArea
@onready var mainScene : Node3D = BasicClassFunctions.findChildOfClass(get_tree().get_root(), "Node3D").child
@onready var player : CharacterBody3D = mainScene.get_node("Player")

var isVisible : bool = false
const SPEED : float = 3.0

var isControlled : bool = false

var bodyType := "BasicEnemy"

func _on_visible_on_screen_notifier_3d_screen_entered():
	isVisible = true
func _on_visible_on_screen_notifier_3d_screen_exited():
	isVisible = false

var playerPos : Vector3 = Vector3.ZERO
var isKnockback : bool = false
var currentKnockbackFrames : int = 0

var currentHealth := enemyHealth

func _physics_process(delta):
	if playerPos.distance_to(player.global_position) > .5:
		playerPos = player.global_position
		navAgent.target_position = playerPos
	if !isControlled:
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
			direction = direction.normalized()
			
			if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			move_and_slide()
	else:
		$Sprite3D.render_priority = 2

func takeDamage(damage : float):
	isKnockback = true
	currentHealth -= damage
	if currentHealth <= 0:
		queue_free()


func _on_hit_area_body_entered(body):
	if body == player:
		player.takeDamage(10.0, global_position)
