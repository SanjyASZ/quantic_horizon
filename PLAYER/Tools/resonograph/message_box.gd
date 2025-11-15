extends Control

@export var messageText: String
@export var texture: Texture

@onready var margin_container: MarginContainer = $NinePatchRect/MarginContainer
@onready var label: Label = $NinePatchRect/MarginContainer/Label
@onready var texture_rect: TextureRect = $NinePatchRect/MarginContainer/TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if messageText:
		label.visible = true
		label.text = messageText
	elif texture:
		texture_rect.visible = true
		texture_rect.texture = texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var marginSide = (margin_container.get_theme_constant("margin_left")
						+ margin_container.get_theme_constant("margin_right"))
	if messageText:
		label.visible = true
		label.text = messageText
		texture_rect.visible = true
		texture_rect.texture = texture
		$NinePatchRect.size.x = label.size.x + marginSide

#↑↓→←↑↓→←
