extends Control
@onready var dialogue: DialogueLabel = $Dialogue2
@onready var player: CharacterBody3D = $"../Player"
@onready var voix: AudioStreamPlayer = $TutorialPart2
@onready var voix_final: AudioStreamPlayer = $TutorialPart3

var paused_position:= 0.0
var wait := false

func _process(_delta):
	if dialogue.message_id == 1:
		dialogue.next_message()
	
	if Global.tutorial_phase_2:
		voix.play()
		dialogue.start_dialogue()
		dialogue.next_message()
		Global.tutorial_phase_2 = false
	
	if voix.get_playback_position() > 18.30 and !wait and dialogue.message_id == 2:
		paused_position = voix.get_playback_position()
		voix.stop()
		wait = true

	if Global.time_hour >= 8  and Global.time_hour <= 9 and wait and dialogue.message_id == 2:
		voix.play(paused_position)
		wait = false
		dialogue.next_message()
	
	if voix.get_playback_position() > 43.15 and !wait and dialogue.message_id == 3:
		paused_position = voix.get_playback_position()
		voix.stop()
		wait = true
		
	if Global.tutorial_platform and dialogue.message_id == 3:
		dialogue.next_message()
		voix.play(paused_position)
		wait = false
		Global.tutorial_platform = false
	
	if voix.get_playback_position() > 56.25 and !wait and dialogue.message_id == 4:
		dialogue.next_message()
	
	if !voix.is_playing() and Global.tutorial_cube and dialogue.message_id == 5:
		dialogue.next_message()
		voix_final.play()
		Global.tutorial_cube = false
		Global.cube_detect_player = true
		wait = false
	
	if voix_final.get_playback_position() > 24.8 and dialogue.message_id == 6:
		dialogue.next_message()
	
	if voix_final.get_playback_position() > 33.69 and !wait and dialogue.message_id == 7:
		wait = true
		paused_position = voix_final.get_playback_position()
		voix_final.stop()
	
	if Global.tutorial_tour and dialogue.message_id == 7:
		wait = false
		dialogue.next_message()
		voix_final.play(paused_position)
	
	if voix_final.get_playback_position() > 47.0 and dialogue.message_id == 8:
		dialogue.next_message()
	
func onDialogueEnded():
	queue_free()
