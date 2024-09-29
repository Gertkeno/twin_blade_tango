extends Control

@export_file("*.tscn") var next_scene: String

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton and !event.pressed:
		set_process_input(false)

		ResourceLoader.load_threaded_request(next_scene, "PackedScene")
		
		var tween := create_tween()
		tween.tween_property(self, "modulate", Color.BLACK, 1.2)
		await tween.finished
		var next_scene_scene: PackedScene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(next_scene_scene)
