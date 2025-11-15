extends Node3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var time_start: float = 0
@onready var elapsed_time: float = 0
@onready var current_radius: float = 0.5
@onready var time_now: float = 0
@onready var sphere_mesh = mesh_instance_3d.mesh
@onready var on_going_scan:bool = false
@onready var current_transparency: float  = 1.0
@onready var material = sphere_mesh as StandardMaterial3D
@onready var resonograph_range: CollisionShape3D = $Area3D/resonograph_range
@onready var Player: Node3D = get_node("../")
@onready var dark_impact_sound: AudioStreamPlayer = $DarkImpactSound
@onready var sonar_ping: AudioStreamPlayer = $SonarPing
@onready var translocator_detected

var message_box: PackedScene = preload("res://UI/message_box.tscn")
var message_box_inst
var message_box_instancied: bool = false
var resonograph_tp_trigger: bool = false
var message_size: int = 0

var code_translocator_1 = "•◘○◙•◘○◙"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh_instance_3d.visible = false

# Don't forget to turn off back-face culling of interior sphere shape won't work
func _process(delta: float) -> void:
	teleport_to_tranlocator()
	# resonograph activation
	if Input.is_action_just_pressed("resonograph") and !on_going_scan:
		# reset scan
		reset_translocator_detected()
		sphere_mesh.set_radius(0.5)
		sphere_mesh.set_height(1)
		current_radius = 0.5
		current_transparency = 1.0
		on_going_scan = true
		# timer
		$Timer.start(0.0)
		mesh_instance_3d.visible = true
		elapsed_time = 0
		time_start = Time.get_unix_time_from_system()
		# sound
		dark_impact_sound.pitch_scale = 1.0
		dark_impact_sound.play()
		
	# resonograph dectection
	if elapsed_time < 3 and on_going_scan:
		# detect 
		translocator_detected = $Area3D.get_overlapping_bodies()
		# collision shape range expansion
		resonograph_range.shape.radius = current_radius
		for obj in translocator_detected:
			if obj.is_in_group("fixed_translocator"):
				if obj.play_sonar:
					obj.translocator_detected()
					
		# 3d animation for scan
		current_radius = lerp(current_radius, 3*1000.0, elapsed_time / 3.0 * delta)
		sphere_mesh.set_radius(current_radius)
		sphere_mesh.set_height(current_radius*2)
		current_transparency = lerp(current_transparency, 0.0, elapsed_time / 1.0 * delta)
		sphere_mesh.material.albedo_color.a = current_transparency
				
		# time calcul 		
		time_now = Time.get_unix_time_from_system()
		elapsed_time = time_now - time_start 
		
	# resonograph end of dectection
	if elapsed_time >= 3:
		on_going_scan = false
		sphere_mesh.set_radius(0.5)
		sphere_mesh.set_height(1.0)
		current_radius = 0.5
		current_transparency = 1.0
		
func _on_timer_timeout() -> void:
	reset_translocator_detected()
	
func reset_translocator_detected() -> void:
	translocator_detected = $Area3D.get_overlapping_bodies()
	for obj in translocator_detected:
		if obj.is_in_group("fixed_translocator"):
			obj.translocator_added = false
			obj.play_sonar = true
			obj.sonar_ping.stop()
	Global.all_translocator_detected = []
	translocator_detected = []
	$Area3D.monitoring = false
	$Area3D.monitoring = true

func teleport_to_tranlocator() -> void:
	if Input.is_action_just_pressed("resonograph_tp_trigger") and !resonograph_tp_trigger:
		resonograph_tp_trigger = true
	elif Input.is_action_just_pressed("resonograph_tp_trigger") and resonograph_tp_trigger:
		resonograph_tp_trigger = false
		message_box_instancied = false
		get_tree().current_scene.remove_child(message_box_inst)
	if resonograph_tp_trigger and Global.all_translocator_detected.size()>0:
		if ! message_box_instancied:
			message_size = 0
			message_box_inst = message_box.instantiate()
			message_box_instancied = true
			get_tree().current_scene.add_child(message_box_inst)
		if Input.is_action_just_pressed("ui_left") and message_size < 14:
			message_size += 1
			message_box_inst.messageText = message_box_inst.messageText + "•"
		elif Input.is_action_just_pressed("ui_right") and message_size < 14:
			message_size += 1
			message_box_inst.messageText = message_box_inst.messageText + "◘"
		elif Input.is_action_just_pressed("ui_up") and message_size < 14:
			message_size += 1
			message_box_inst.messageText = message_box_inst.messageText + "○"
		elif Input.is_action_just_pressed("ui_down") and message_size < 14:
			message_size += 1
			message_box_inst.messageText = message_box_inst.messageText + "◙"
			
		if Input.is_action_just_pressed("activate_tp_trigger"):
			if message_box_inst.messageText == code_translocator_1:
				Player.global_position = Vector3(233,50+1.59985,171)
				# Global.all_translocator_detected[message_size][0]
				
