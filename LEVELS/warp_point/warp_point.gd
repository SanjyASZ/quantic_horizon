extends RigidBody3D
@onready var ring_001_ring_1_mat_0: MeshInstance3D = $Ring001_Ring1_Mat_0
@onready var ring_001_ring_1_mat_1: MeshInstance3D = $Ring001_Ring1_Mat_1
@onready var translocator_added:bool = false
@onready var sonar_ping: AudioStreamPlayer = $SonarPing
@onready var play_sonar:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ring_001_ring_1_mat_0.rotate(Vector3(0, 1, 0), PI * delta)
	ring_001_ring_1_mat_1.rotate(Vector3(0, 0, 1), PI * delta)

func translocator_detected():
	if !translocator_added:
		Global.all_translocator_detected.append([self.global_position])
		translocator_added = true
		if !sonar_ping.is_playing():
			sonar_ping.play()
			play_sonar = false 
		else:
			while sonar_ping.is_playing():
				await get_tree().create_timer(0.1).timeout
			sonar_ping.play()
			play_sonar = false
