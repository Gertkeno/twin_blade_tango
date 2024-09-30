extends Area3D

@export_file("*.tscn") var next_scene: String

var pcount: int = 0
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		pcount += 1

		print(pcount)
		if pcount >= 2:
			print("WIN")
			get_tree().change_scene_to_file(next_scene)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		pcount -= 1
