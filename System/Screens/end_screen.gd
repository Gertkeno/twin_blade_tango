extends Control

func _ready() -> void:
	$Menu.grab_focus()
	$Exit.disabled = OS.get_name() == "Web"

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://System/Screens/Start_Screen.tscn")

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://System/Screens/controller_selection.tscn")
