extends HBoxContainer

const full_heart = preload("res://Assets/Interface/heart_full_16x16.png")
const empty_heart = preload("res://Assets/Interface/heart_empty_16x16.png")
const half_heart = preload("res://Assets/Interface/heart_half_16x16.png")
func update_value(health: int) -> void:
	var h := health
	for child in get_children():
		if h == 1:
			child.texture = half_heart
		elif h > 0:
			child.texture = full_heart
		else:
			child.texture = empty_heart
		h -= 2
