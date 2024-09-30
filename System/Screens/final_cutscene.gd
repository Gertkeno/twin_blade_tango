extends Node3D


func _on_animation_player_animation_finished(_anim_name: String) -> void:
	get_tree().change_scene_to_file("res://System/Screens/End_Screen.tscn")
