extends Control

func _ready() -> void:
	$Menu.grab_focus()
	$Exit.disabled = OS.get_name() == "Web"


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://System/Screens/Start_Screen.tscn")


func _on_restart_pressed() -> void:
	if GameMode.player_count == 2:
		get_tree().change_scene_to_file("res://System/Screens/controller_selection.tscn")
	elif GameMode.player_count == 1:
		get_tree().change_scene_to_file("res://System/Screens/controller_selection_cpu.tscn")
