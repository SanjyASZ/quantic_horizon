extends Node2D
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var center: Sprite2D = $CanvasLayer/Center
@onready var resonograph_icon: Sprite2D = $CanvasLayer/Center/resonograph_icon
@onready var translocator_icon: Sprite2D = $CanvasLayer/Center/translocator_icon
@onready var disruptor_icon: Sprite2D = $CanvasLayer/Center/disruptor_icon
@onready var hand_icon: Sprite2D = $CanvasLayer/Center/hand_icon

@onready var menu_open: AudioStreamPlayer = $MenuClick357350
@onready var select: AudioStreamPlayer = $Select

@onready var screen_width = get_viewport().get_size().x
@onready var offset_x = screen_width / 2
@onready var screen_length = get_viewport().get_size().y
@onready var offset_y = screen_length

var menu_active = false
var is_selecting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center.global_position = get_viewport().get_size() / 2
	resonograph_icon.global_position = get_viewport().get_size() / 2
	translocator_icon.global_position = get_viewport().get_size() / 2
	disruptor_icon.global_position = get_viewport().get_size() / 2
	hand_icon.global_position = get_viewport().get_size() / 2
	center.visible = false
	resonograph_icon.visible = false
	translocator_icon.visible = false
	disruptor_icon.visible = false
	hand_icon.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Input
	if Input.is_action_just_pressed("radial_menu"):
		center.visible = true
		resonograph_icon.visible = true
		translocator_icon.visible = true
		disruptor_icon.visible = true
		hand_icon.visible = true
		menu_active = true
		if menu_open.is_playing:
			menu_open.stop()
		menu_open.play()
	elif Input.is_action_just_released("radial_menu"):
		menu_active = false
	
	if menu_active:
		print("MENU_ACTIVE")
		if Input.is_action_just_pressed("joy_cam_down"):
			translocator_icon.visible = false
			resonograph_icon.visible = false
			disruptor_icon.visible = true
			hand_icon.visible = false
			# tools = [ translocator, resonograph, disruptor, hand ]
			Global.tools = [ false, false, true, false]
			if select.is_playing:
				select.stop()
			select.play()
		elif Input.is_action_just_pressed("joy_cam_right"):
			translocator_icon.visible = false
			resonograph_icon.visible = true
			disruptor_icon.visible = false
			hand_icon.visible = false
			# tools = [ translocator, resonograph, disruptor, hand ]
			Global.tools = [ false, true, false, false]
			if select.is_playing:
				select.stop()
			select.play()
		elif Input.is_action_just_pressed("joy_cam_up"):
			translocator_icon.visible = false
			resonograph_icon.visible = false
			disruptor_icon.visible = false
			hand_icon.visible = true
			# tools = [ translocator, resonograph, disruptor, hand ]
			Global.tools = [ false, false, false, true]
			if select.is_playing:
				select.stop()
			select.play()
		elif Input.is_action_just_pressed("joy_cam_left"):
			translocator_icon.visible = true
			resonograph_icon.visible = false
			disruptor_icon.visible = false
			hand_icon.visible = false
			# tools = [ translocator, resonograph, disruptor, hand ]
			Global.tools = [ true, false, false, false]
			if select.is_playing:
				select.stop()
			select.play()
			
	# ANIMATION
	if menu_active:
		resonograph_icon.position = lerp(resonograph_icon.position, Vector2(offset_x, 0), 4 * delta)
		translocator_icon.position = lerp(translocator_icon.position, Vector2(-offset_x, 0), 4 * delta)
		disruptor_icon.position = lerp(disruptor_icon.position, Vector2(0, offset_y), 4 * delta)
		hand_icon.position = lerp(hand_icon.position, Vector2(0, -offset_y), 4 * delta)
	else:
		resonograph_icon.position = lerp(resonograph_icon.position, Vector2(0, 0), 8 * delta)
		translocator_icon.position = lerp(translocator_icon.position, Vector2(0, 0), 8 * delta)
		disruptor_icon.position = lerp(disruptor_icon.position, Vector2(0,0), 8 * delta)
		hand_icon.position = lerp(hand_icon.position, Vector2(0,0), 8 * delta)
	if resonograph_icon.position.distance_to(Vector2(0,0)) <= offset_x / 16:
		center.visible = false
		resonograph_icon.visible = false
		translocator_icon.visible = false
		disruptor_icon.visible = false
		hand_icon.visible = false
