extends CharacterBody3D

# another scene
@onready var model: Node3D = $model
@onready var xbot:= $model/x_bot
@onready var camera: Camera3D = $CameraController/Camera3D

# gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# CONST SPEED
var player_speed := 3.0

@export var base_speed := 3.0
@export var run_speed := 7.0

# Jump mechanic
@export var jump_height := 1.3
@export var jump_time_to_peak := 0.4
@export var jump_time_to_descent := 0.3

# check pefeper: jump 
@export var jump_velocity := ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@export var jump_gravity := ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@export var fall_gravity := ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

# player_state

var is_running := false
var is_falling := false
var is_idle := true

var movement_input = Vector2.ZERO

func _input(event):
	if event.is_action_pressed("left_click"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	move_logic(delta)
	jump_logic(delta)
	
	_set_animation()
	move_and_slide()

func jump_logic(delta) -> void:
	if is_on_floor():
		is_falling = false
		if Input.is_action_pressed("jump"):
			velocity.y = -jump_velocity
	else:
		is_falling = true
	gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta
	
func move_logic(delta) -> void:
	movement_input = Input.get_vector("left","right","forward","backward").rotated(-camera.global_rotation.y)
	var vel_2d = Vector2(velocity.x,velocity.z)
	# player start moving
	if movement_input != Vector2.ZERO:
		# player start running
		if Input.is_action_pressed("run"):
			is_running = true
			is_idle = false
			player_speed = run_speed
		# player start walking
		else:
			is_running = false
			is_idle = false
			player_speed = base_speed
			
		# calculate movespeed according to state
		vel_2d += movement_input * player_speed
		vel_2d = vel_2d.limit_length(player_speed)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y # .Y = 2eme composante du vecteur 2d
		
		# rotate model to look toward good direction
		var target_angle = -movement_input.angle() - PI/2
		model.rotation.y = rotate_toward(model.rotation.y, target_angle, 14 * delta) 
		
	# player stop moving
	else:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, player_speed * 16.0 * delta)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y # .Y = 2eme composante du vecteur 2d
		is_idle = true

func _set_animation():
	if is_idle and not is_falling:
		xbot.set_move_state("Idle0")
	elif is_falling:
		is_running = false
		is_idle = false
		xbot.set_move_state("Falling_Idle0")
	else:
		if is_running and not is_falling: 
			xbot.set_move_state("Running0")
			is_falling = false
		elif not is_falling: 
			xbot.set_move_state("Walking0")
			is_falling = false
