extends Node

const RADIAL_MENU = preload("res://UI/RadialMenu/radial_menu.tscn")

var all_translocator_detected = []
# tools = [ translocator, resonograph, disruptor, hand ]
var tools = [ false, false, false, false]
var is_time_altered = false

var radial_menu_instanciated = false
var radial_menu 

func _process(_delta):
	if !radial_menu_instanciated and !is_time_altered:
		radial_menu = RADIAL_MENU.instantiate()
		get_tree().current_scene.add_child(radial_menu)
		radial_menu_instanciated = true
	if is_time_altered:
		get_tree().current_scene.remove_child(radial_menu)
		radial_menu_instanciated = false
		
func _input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()
		
