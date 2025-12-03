extends Node

const RADIAL_MENU = preload("res://UI/RadialMenu/radial_menu.tscn")

var all_translocator_detected = []
# tools = [ translocator, resonograph, disruptor, hand ]
var tools = [ false, false, false, false]
var is_time_altered = false

# Radial menu
var radial_menu_instanciated = false
var radial_menu 

# Dialogue
var tutorial_phase_2 := false

# Time 
var time_hour:= 0.0 

# Tutorial 
var tutorial_platform:= false
var tutorial_cube:= false
var tutorial_tour:= false
var cube_detect_player := false

func _process(_delta):
	if !radial_menu_instanciated and !is_time_altered:
		radial_menu = RADIAL_MENU.instantiate()
		get_tree().current_scene.add_child(radial_menu)
		radial_menu_instanciated = true
	if is_time_altered and radial_menu_instanciated:
		if radial_menu and is_instance_valid(radial_menu):
			radial_menu.queue_free()
			radial_menu = null
		radial_menu_instanciated = false

func _input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()

# ✅ BONUS : Nettoyer à la fermeture
func _exit_tree():
	if radial_menu and is_instance_valid(radial_menu):
		radial_menu.queue_free()
