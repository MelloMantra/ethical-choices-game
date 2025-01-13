extends CharacterBody3D

@export var walkSpeed = 10
@export var aggroSpeed = 15

func _physics_process(delta: float) -> void:
	
	move_and_slide()


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	
