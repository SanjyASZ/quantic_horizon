extends Node

const SLOW_MO_DISABLE = preload("res://AUDIO/SFX/slow_mo_disable.mp3")
const SLOW_MO_ENABLE = preload("res://AUDIO/SFX/slow_mo_enable.mp3")
const RADIAL_MENU = preload("res://UI/RadialMenu/radial_menu.tscn")

var all_translocator_detected = []
# tools = [ translocator, resonograph, disruptor, hand ]
var tools = [ false, false, false, false]
var is_time_slowed = false
var audio_player: AudioStreamPlayer

var radial_menu_instanciated = false
var radial_menu 

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
func _process(_delta):
	if !radial_menu_instanciated and !is_time_slowed:
		radial_menu = RADIAL_MENU.instantiate()
		get_tree().current_scene.add_child(radial_menu)
		radial_menu_instanciated = true
	if is_time_slowed:
		get_tree().current_scene.remove_child(radial_menu)
		radial_menu_instanciated = false

# Global input better than using it in process for non physics object
func _input(event):
	if tools[2]:
		# Menu to quit game
		if event.is_action_pressed("quit"):
			get_tree().quit()
			
		if event.is_action_pressed("use_tool") and is_time_slowed:
			Engine.time_scale = 1
			is_time_slowed = false
			audio_player.stream = SLOW_MO_DISABLE 
			audio_player.play()
		elif event.is_action_pressed("use_tool") and not is_time_slowed:
			Engine.time_scale = 60
			is_time_slowed = true
			audio_player.stream = SLOW_MO_ENABLE
			audio_player.play()
		
