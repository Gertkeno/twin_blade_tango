extends Control

func _ready() -> void:
	$VBoxContainer/Start.grab_focus()
	$VBoxContainer/Exit.disabled = OS.get_name() == "Web"


var locked: bool = false
func load_game_scene(scene: String) -> void:
	if locked:
		return

	locked = true
		
	ResourceLoader.load_threaded_request(scene, "PackedScene")
	$AnimationPlayer.play("start_select")
	await $AnimationPlayer.animation_finished
	var tutorial_scene: PackedScene = ResourceLoader.load_threaded_get(scene)
	get_tree().change_scene_to_packed(tutorial_scene)


@export_file("*.tscn") var next_screen: String
func _on_start_pressed() -> void:
	if not locked:
		GameMode.player_count = 2
		load_game_scene(next_screen)


func _on_single_player_pressed() -> void:
	if not locked:
		GameMode.player_count = 1
		load_game_scene(next_screen)


func _on_exit_pressed() -> void:
	if !locked:
		get_tree().quit()


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://System/Screens/Credits_Scene.tscn")
