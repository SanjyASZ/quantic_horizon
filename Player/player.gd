extends CharacterBody3D

# another scene
@onready var model: Node3D = $model
@onready var xbot:= $model/x_bot
@onready var camera: Camera3D = $CameraController/Camera3D

@onready var slow_mo_enable: AudioStreamPlayer = $SlowMoEnable
@onready var slow_mo_disable: AudioStreamPlayer = $SlowMoDisable
@onready var warp: AudioStreamPlayer = $Warp

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

# player_state and movement
var is_running := false
var is_falling := false
var is_idle := true
var movement_input = Vector2.ZERO

# Translocator
var translocator = preload("res://Player/translocator.tscn")
var can_throw_translocator = true
var can_throw_translocator_timer = true

# Time slow
var is_time_slowed = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#await self.ready

func _input(event):
	if event.is_action_pressed("slow_time") and is_time_slowed:
		Engine.time_scale = 1
		is_time_slowed = false
		slow_mo_disable.play()
	elif event.is_action_pressed("slow_time") and not is_time_slowed:
		Engine.time_scale = 60
		is_time_slowed = true
		slow_mo_enable.play()

	if event.is_action_pressed("quit"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	move_logic(delta)
	jump_logic(delta)
	_set_animation()
	move_and_slide()
	translocator_throw()

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

func translocator_throw():
	if can_throw_translocator_timer:
		if Input.is_action_just_pressed("throw_translocator") and can_throw_translocator:
			can_throw_translocator_timer = false
			can_throw_translocator = false
			var translocator_inst = translocator.instantiate()
			translocator_inst.position = $model/translocator_spawn.global_position
			get_tree().current_scene.add_child(translocator_inst)
			var _force = -15
			var _up_direction = 3
			
			var player_rotation = camera.global_transform.basis.z.normalized()
			translocator_inst.apply_central_impulse(player_rotation  * _force + Vector3(0,_up_direction,0))
			$translocator_throw_timer.start()
			

func _on_translocator_throw_timer_timeout() -> void:
	can_throw_translocator_timer = true
