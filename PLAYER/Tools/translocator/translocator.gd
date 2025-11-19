extends RigidBody3D

@onready var Player = get_node("../Player")
@onready var warp_sound: AudioStreamPlayer = $warp_sound
@onready var warp_vfx = get_node("warp_effect/GPUParticles3D") 
@onready var ring_001_ring_1_mat_0: MeshInstance3D = $Ring001_Ring1_Mat_0
@onready var ring_001_ring_1_mat_1: MeshInstance3D = $Ring001_Ring1_Mat_1
@onready var translocator_index = 0
@onready var translocator_added = false

# ✅ AJOUT : Timer réutilisable au lieu de create_timer()
var reusable_timer: Timer

func _ready() -> void:
	# ✅ CRÉER UN SEUL TIMER RÉUTILISABLE
	reusable_timer = Timer.new()
	add_child(reusable_timer)
	reusable_timer.one_shot = false
	reusable_timer.wait_time = 0.1

func _process(_delta: float) -> void:
	if Player.can_throw_translocator_timer:
		# verif key pressed can throw and no above collision
		if Input.is_action_just_pressed("use_tool") and not Player.can_throw_translocator and $Area3D.get_overlapping_bodies().size() == 0:
			_teleport_player(1.0)
			
		if Input.is_action_just_pressed("special_tool") and not Player.can_throw_translocator:
			_cancel_translocator(2.0)

# ✅ NOUVELLE FONCTION : Éviter la duplication de code
func _teleport_player(pitch: float) -> void:
	warp_vfx.emitting = true
	ring_001_ring_1_mat_0.visible = false
	ring_001_ring_1_mat_1.visible = false
	
	if not warp_sound.is_playing():
		warp_sound.pitch_scale = pitch
		warp_sound.play()
	
	# ✅ ATTENDRE LA FIN DU SON (méthode plus propre)
	Player.can_throw_translocator_timer = false
	Player.can_throw_translocator = false
	
	# Téléporter le joueur si pitch == 1.0
	if pitch == 1.0:
		Player.global_position = self.global_position + Vector3(0, 0.59985, 0)
	
	# ✅ CONNECTER LE SIGNAL AU LIEU D'UNE BOUCLE WHILE
	if not warp_sound.finished.is_connected(_on_warp_sound_finished):
		warp_sound.finished.connect(_on_warp_sound_finished)

# ✅ ALIAS pour cancel
func _cancel_translocator(pitch: float) -> void:
	_teleport_player(pitch)

# ✅ CALLBACK PROPRE : Appelé quand le son se termine
func _on_warp_sound_finished() -> void:
	Player.can_throw_translocator_timer = true
	Player.can_throw_translocator = true
	queue_free()

# ✅ IMPORTANT : Nettoyer les connexions
func _exit_tree() -> void:
	if warp_sound and warp_sound.finished.is_connected(_on_warp_sound_finished):
		warp_sound.finished.disconnect(_on_warp_sound_finished)
	if reusable_timer:
		reusable_timer.queue_free()
