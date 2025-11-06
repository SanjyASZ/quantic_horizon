extends Node3D

# mouse sensitivity
@export var vertical_sensitivity = 0.0007
@export var horizontal_sensitivity = 0.0007

# Joystick sensitivity
@export var joy_vertical_sensitivity = 2.0
@export var joy_horizontal_sensitivity = 1.0

# revers movement camera
@export var reverse_vertical = -1
@export var reverse_horizontal = 1

# joystick movement camera
#func _process(delta: float) -> void:
	#var joy_dir = Input.get_vector("pan_left","pan_right","pan_up","pan_down")
	#rotate_from_vector(joy_dir * delta * Vector2(joy_horizontal_sensitivity,joy_vertical_sensitivity) )

# mouse movement camera
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative)

# rotate camera function 
func rotate_from_vector(v: Vector2):
	if v.length() == 0: return
	rotation.y += v.x * reverse_vertical * vertical_sensitivity
	rotation.x += v.y * reverse_horizontal * horizontal_sensitivity
	rotation.x = clamp(rotation.x, -1.3, 0.5)
