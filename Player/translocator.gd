extends RigidBody3D

@onready var Player = get_node("../Player")
@onready var warp_sound: AudioStreamPlayer = $warp_sound
@onready var warp_vfx = get_node("warp_effect/GPUParticles3D") 
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Player.can_throw_translocator_timer:
		if Input.is_action_just_pressed("translocator_swap") and not Player.can_throw_translocator and $Area3D.get_overlapping_bodies().size() == 0:
			if ! warp_sound.is_playing():
				warp_sound.pitch_scale = 1.0
				warp_sound.play()
			warp_vfx.emitting = true
			Player.global_position = $".".global_position + Vector3(0,0.59985,0)
			mesh_instance_3d.visible = false
			while warp_sound.is_playing():
				await get_tree().create_timer(0.01).timeout
			Player.can_throw_translocator_timer = true
			Player.can_throw_translocator = true
			queue_free()
			
		if Input.is_action_just_pressed("throw_translocator") and not Player.can_throw_translocator:
			if ! warp_sound.is_playing():
				warp_sound.pitch_scale = 2.0
				warp_sound.play()
			warp_vfx.emitting = true
			mesh_instance_3d.visible = false
			while warp_sound.is_playing():
				await get_tree().create_timer(0.01).timeout
			Player.can_throw_translocator_timer = true
			Player.can_throw_translocator = true
			queue_free()
