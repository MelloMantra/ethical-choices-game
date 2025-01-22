extends CharacterBody3D

@onready var mainScene : Node3D = BasicClassFunctions.findChildOfClass(get_tree().get_root(), "Node3D").child
@onready var player : CharacterBody3D = mainScene.get_node("Player")

const SPEED = 6.0
var direction


func _physics_process(delta: float) -> void:

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	var collision : KinematicCollision3D = move_and_collide(velocity*delta)
	if collision:
		var collisionObject = collision.get_collider()
		
		if collisionObject:
			print(collisionObject)
			if collisionObject==player:
				player.takeDamage(10, global_position)
			queue_free()
