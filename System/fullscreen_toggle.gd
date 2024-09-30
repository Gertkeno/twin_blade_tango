extends Node


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Fullscreen"):
		var mode := DisplayServer.window_get_mode()
		var window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if window else DisplayServer.WINDOW_MODE_WINDOWED)
