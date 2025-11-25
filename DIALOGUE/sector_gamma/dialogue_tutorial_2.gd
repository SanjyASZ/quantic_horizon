extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer2
@onready var voix: AudioStreamPlayer = $AnimationPlayer2/TutorialPart2
@onready var dialogue: DialogueLabel = $Dialogue2
@onready var player: CharacterBody3D = $"../Player"
var skip = false

func _process(_delta):
	if Global.start_D2 and !skip:
		print("INSIDE")
		dialogue.start_dialogue()
		animation_player.play("start_dialogue_2")
		voix.play()
		skip = true
	
func next_message():
	dialogue.next_message()

func pause_anim():
	animation_player.pause()
	voix.stream_paused = true
	
func play_anim():
	animation_player.play()
	voix.stream_paused = false
	
func onMessageFinished():
	if dialogue.message_id in [0,1]:
		dialogue.next_message()
	
func onDialogueEnded():
	queue_free()
