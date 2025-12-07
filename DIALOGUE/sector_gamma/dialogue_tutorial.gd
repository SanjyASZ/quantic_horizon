extends Control
@onready var dialogue = $Dialogue
@onready var player: CharacterBody3D = $"../Player"
@onready var voix: AudioStreamPlayer = $TutorialPart1
var wait_lamp := true
var paused_position:= 0.0
var tuto_phase_2:= false

func _ready():
	voix.play()
	dialogue.start_dialogue()
	dialogue.next_message()

func _process(_delta):
	if voix.get_playback_position() > 46.0 and wait_lamp and !tuto_phase_2:
		paused_position = voix.get_playback_position()
		voix.stop()
		wait_lamp = false
		
	if player.flashlight.visible and !wait_lamp:
		voix.play(paused_position)
		dialogue.next_message()
		wait_lamp = true
		tuto_phase_2 = true

	if dialogue.message_id in [0,1,6]:
		dialogue.next_message()
	elif dialogue.message_id == 2 and voix.get_playback_position() > 21.0:
		dialogue.next_message()
	elif dialogue.message_id == 3 and voix.get_playback_position() > 32.0:
		dialogue.next_message()
	elif dialogue.message_id == 5 and voix.get_playback_position() > 58.58:
		dialogue.next_message()
		
func onDialogueEnded():
	Global.tutorial_phase_2 = true
	const DIALOGUE_SCENE = preload("res://DIALOGUE/sector_gamma/dialogue_2.tscn")
	var dialogue_instance = DIALOGUE_SCENE.instantiate()
	get_parent().add_child(dialogue_instance)
	queue_free()
