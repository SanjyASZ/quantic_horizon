extends Area3D
@onready var area_3d: Area3D = $Area3D

# Connecter le signal dans _ready
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Global.tutorial_platform = true
		Global.cube_detect_player = true
	if body.is_in_group("floor"):
		if Global.cube_detect_player:
			Global.tutorial_cube = true
			print("FREE CUBE AREA")
			queue_free()
