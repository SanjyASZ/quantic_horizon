extends Node3D

# mouse sensitivity
@export var vertical_sensitivity: float = 0.0007
@export var horizontal_sensitivity: float  = 0.0007

# Joystick sensitivity
@export var joy_vertical_sensitivity: float  = 100.0
@export var joy_horizontal_sensitivity: float  = 50.0

# revers movement camera
@export var reverse_vertical: float  = -1.0
@export var reverse_horizontal: float  = 1.0

 #joystick movement camera with delta ?
func _process(_delta: float) -> void:
	var joy_dir = Input.get_vector("joy_cam_left","joy_cam_right","joy_cam_up","joy_cam_down")
	rotate_from_vector(joy_dir * Vector2(joy_horizontal_sensitivity,joy_vertical_sensitivity) )

# mouse movement camera
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative)
	
# rotate camera function 
func rotate_from_vector(v: Vector2):
	if v.length() == 0: return
	rotation.y += v.x * reverse_vertical * vertical_sensitivity
	rotation.x += v.y * reverse_horizontal * horizontal_sensitivity
	rotation.x = clamp(rotation.x, -1.5, 0.9)
