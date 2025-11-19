extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var voix: AudioStreamPlayer = $TutorialPart1
@onready var dialogue = $Dialogue
@onready var player: CharacterBody3D = $"../Player"
var skip_1 = true

func _ready():
	dialogue.start_dialogue()
	animation_player.play("start_dialogue")
	voix.play()
	dialogue.next_message()

func _process(_delta):
	print(dialogue.message_id)
	if player.flashlight.visible == true and !skip_1:
		print("PLAY")
		voix.stream_paused = false
		skip_1 = true
		dialogue.next_message()
		
func startD3():
	dialogue.next_message()

func startD4():
	dialogue.next_message()

func pause():
	animation_player.pause()
	voix.stream_paused = true
	skip_1 = false
	
func startD6():
	dialogue.next_message()

func onMessageFinished():
	if dialogue.message_id in [0,1]:
		dialogue.next_message()
	if dialogue.message_id in [5]:
		dialogue.next_message()
	
func onDialogueEnded():
	queue_free()
