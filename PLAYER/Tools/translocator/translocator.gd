extends RigidBody3D

@onready var Player = get_node("../Player")
@onready var warp_sound: AudioStreamPlayer = $warp_sound
@onready var warp_vfx = get_node("warp_effect/GPUParticles3D") 
@onready var ring_001_ring_1_mat_0: MeshInstance3D = $Ring001_Ring1_Mat_0
@onready var ring_001_ring_1_mat_1: MeshInstance3D = $Ring001_Ring1_Mat_1
@onready var translocator_index = 0
@onready var translocator_added = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Player.can_throw_translocator_timer:
		# verif key pressed can throw and no above collision
		if Input.is_action_just_pressed("use_tool") and not Player.can_throw_translocator and $Area3D.get_overlapping_bodies().size() == 0:
			warp_vfx.emitting = true
			Player.global_position = $".".global_position + Vector3(0,0.59985,0)
			ring_001_ring_1_mat_0.visible = false
			ring_001_ring_1_mat_1.visible = false
			if ! warp_sound.is_playing():
				warp_sound.pitch_scale = 1.0
				warp_sound.play()
			while warp_sound.is_playing():
				Player.can_throw_translocator_timer = false
				Player.can_throw_translocator = false
				await get_tree().create_timer(0.1).timeout
			if ! warp_sound.is_playing():
				Player.can_throw_translocator_timer = true
				Player.can_throw_translocator = true
				queue_free()
			
		if Input.is_action_just_pressed("special_tool") and not Player.can_throw_translocator:
			warp_vfx.emitting = true
			ring_001_ring_1_mat_0.visible = false
			ring_001_ring_1_mat_1.visible = false
			if ! warp_sound.is_playing():
				warp_sound.pitch_scale = 2.0
				warp_sound.play()
			while warp_sound.is_playing():
				Player.can_throw_translocator_timer = false
				Player.can_throw_translocator = false
				await get_tree().create_timer(0.1).timeout
			if ! warp_sound.is_playing():
				Player.can_throw_translocator_timer = true
				Player.can_throw_translocator = true
				queue_free()
