extends Control

func _ready() -> void:
	$Start.grab_focus()
	if OS.get_name() == "Web":
		$Exit.hide()


@export_file("*.tscn") var next_screen: String
var locked: bool = false
func _on_start_pressed() -> void:
	if locked:
		return

	locked = true
		
	ResourceLoader.load_threaded_request(next_screen, "PackedScene")
	$AnimationPlayer.play("start_select")
	await $AnimationPlayer.animation_finished
	var tutorial_scene: PackedScene = ResourceLoader.load_threaded_get(next_screen)
	get_tree().change_scene_to_packed(tutorial_scene)


func _on_exit_pressed() -> void:
	if !locked:
		get_tree().quit()


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://System/Screens/Credits_Scene.tscn")
