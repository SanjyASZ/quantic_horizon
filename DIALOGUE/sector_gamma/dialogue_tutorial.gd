extends Control
@onready var dialogue = $Dialogue
@onready var player: CharacterBody3D = $"../Player"
@onready var voix: AudioStreamPlayer = $TutorialPart1
var wait_lamp := true
var paused_position:= 0.0

func _ready():
	voix.play()
	dialogue.start_dialogue()
	dialogue.next_message()

func _process(_delta):
	if voix.get_playback_position() > 46.0 and wait_lamp:
		paused_position = voix.get_playback_position()
		voix.stop()
		if player.flashlight.visible == true and wait_lamp:
			wait_lamp = false
			voix.play(paused_position)
			print("LAMP")
			print(dialogue.message_id)
			dialogue.next_message()
			print(dialogue.message_id)
	
	if dialogue.message_id in [0,1,6]:
		dialogue.next_message()
	elif dialogue.message_id == 2 and voix.get_playback_position() > 21.0:
		dialogue.next_message()
	elif dialogue.message_id == 3 and voix.get_playback_position() > 32.0:
		dialogue.next_message()
	elif dialogue.message_id == 5 and voix.get_playback_position() > 58.58:
		dialogue.next_message()
		
func onMessageFinished():
	pass
	
func onDialogueEnded():
	queue_free()
