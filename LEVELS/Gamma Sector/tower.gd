extends Area3D
@onready var area_3d: Area3D = $Area3D

# Connecter le signal dans _ready
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Global.tutorial_tour = true
		queue_free()
