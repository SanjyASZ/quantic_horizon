extends Area3D
#@onready var area_3d: Area3D = $Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Global.tutorial_tour = true

func _process(_delta: float) -> void:
	Global.tower_amplification = has_player_inside()

func has_player_inside() -> bool:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false
