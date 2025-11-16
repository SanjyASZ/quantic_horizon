extends Node
const SLOW_MO_DISABLE = preload("res://AUDIO/SFX/slow_mo_disable.mp3")
const SLOW_MO_ENABLE = preload("res://AUDIO/SFX/slow_mo_enable.mp3")
var audio_player: AudioStreamPlayer

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
# Global input better than using it in process for non physics object
func _input(event):
	if Global.tools[2]:
		if event.is_action_pressed("special_tool") and Global.is_time_altered:
			Engine.time_scale = 1
			Global.is_time_altered = false
			audio_player.stream = SLOW_MO_DISABLE 
			audio_player.play()
		elif event.is_action_pressed("use_tool") and not Global.is_time_altered:
			Engine.time_scale = 60
			Global.is_time_altered = true
			audio_player.stream = SLOW_MO_ENABLE
			audio_player.play()
		
