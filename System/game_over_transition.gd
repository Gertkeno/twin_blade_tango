extends Control

const game_over_screen = "res://System/Screens/GameOver_Screen.tscn"


func _ready() -> void:
	var particles: GPUParticles2D = $Control/GPUParticles2D
	
	particles.restart()
	await particles.finished
	$FadeoutPlayer.play("fadeout")
	await $FadeoutPlayer.animation_finished
	get_tree().change_scene_to_file(game_over_screen)
