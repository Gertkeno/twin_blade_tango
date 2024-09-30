extends PanelContainer


func _ready() -> void:
	$VBoxContainer/Continue.grab_focus()


func _on_continue_pressed() -> void:
	get_tree().paused = false
	self.queue_free()


func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://System/Screens/Start_Screen.tscn")
	self.queue_free()
