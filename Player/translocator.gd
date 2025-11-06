extends RigidBody3D

@onready var Player = get_node("../Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	print( $Area3D.get_overlapping_bodies().size())
	if Player.can_throw_translocator_timer:
		if Input.is_action_just_pressed("translocator_swap") and not Player.can_throw_translocator and $Area3D.get_overlapping_bodies().size() == 0:
			Player.global_position = $".".global_position + Vector3(0,1.8,0)
			Player.can_throw_translocator_timer = false
			Player.can_throw_translocator = true
			queue_free()

		if Input.is_action_just_pressed("throw_translocator") and not Player.can_throw_translocator:
			Player.can_throw_translocator_timer = false
			Player.can_throw_translocator = true
			queue_free()
	
