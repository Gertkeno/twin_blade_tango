extends Control

func _ready() -> void:
	get_tree().paused = false
	$Menu.grab_focus()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://System/Screens/Start_Screen.tscn")

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://System/Screens/controller_selection.tscn")
