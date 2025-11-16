extends Node3D

# mouse sensitivity
@export var vertical_sensitivity: float = 0.0007
@export var horizontal_sensitivity: float  = 0.0007

# Joystick sensitivity
@export var joy_vertical_sensitivity: float  = 100.0
@export var joy_horizontal_sensitivity: float  = 50.0

# grab look sensitivity
@export var look_sensitivity = 0.01

# revers movement camera
@export var reverse_vertical: float  = -1.0
@export var reverse_horizontal: float  = 1.0

# grab pull push mechanic
@onready var grab_ray: RayCast3D = $Camera3D/grab_ray
@onready var grab_target: Node3D = $Camera3D/grab_ray/grab_target

# Grab object
@export var grab_force = 10.0
@export var release_force = 0.4
var grab:RigidBody3D
@onready var camera: Camera3D = $Camera3D

#joystick movement camera with delta ?
func _process(_delta: float) -> void:
	# Joystick control
	var joy_dir = Input.get_vector("joy_cam_left","joy_cam_right","joy_cam_up","joy_cam_down")
	rotate_from_vector(joy_dir * Vector2(joy_horizontal_sensitivity,joy_vertical_sensitivity) )
	if Global.tools[3]:
		#If we are pressing the grab action
		if Input.is_action_pressed("use_tool"):
			if grab: #If there is a grabbed object
				if grab.get_colliding_bodies().is_empty() or (!grab.get_colliding_bodies().is_empty() and grab.get_colliding_bodies()[0] is RigidBody3D): 
					#Is the grabbed object isn't colliding whith anything or that it is colliding with another rigidbody, then keep on grabbing by setting the velocity of the grabbed object to its relative position to the grab target times the grab force
					grab.linear_velocity = grab_force * (grab_target.global_position - grab.global_position)
				else:
					release() #If not, then release the grabbed object
			
			#If there isn't a grabbed object, the grab action was just pressed, the ray hit something and it is a rigidbody
			elif Input.is_action_just_pressed("use_tool") and grab_ray.is_colliding() and grab_ray.get_collider() is RigidBody3D:
				#Set the grabbed object to the ray hit
				grab = grab_ray.get_collider() 
				#Wait for 0.2 seconds to let the player pick up the object before checking for collisions
				await get_tree().create_timer(0.2).timeout
				if grab: #If there is a grabbed object
					grab.max_contacts_reported = 1 #Enable collision check on the grabbed object
					grab.contact_monitor = true #Enable collision check on the grabbed object
		elif grab:
			release() #Release the grabbed object

# mouse movement camera
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative)
		#if Global.tools[3]:
			#rotate_y(event.relative.x * -look_sensitivity)
			#camera.rotate_x(event.relative.y * -look_sensitivity)
			#camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
			
# rotate camera function 
func rotate_from_vector(v: Vector2):
	if v.length() == 0: return
	rotation.y += v.x * reverse_vertical * vertical_sensitivity
	rotation.x += v.y * reverse_horizontal * horizontal_sensitivity
	rotation.x = clamp(rotation.x, -1.5, 0.9)

func release():
	grab.max_contacts_reported = 0 #Disable collision check on the grabbed object
	grab.contact_monitor = false #Disable collision check on the grabbed object
	grab.linear_velocity *= release_force #Apply the release force
	grab = null #Reset the grabbed object
