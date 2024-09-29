extends Node3D

@export var enemy: PackedScene
@export var max_count: int = 6
@export var radius: float = 1

var count: int = 0

func _on_timer_timeout() -> void:
	if count < max_count:
		var rangle := randf_range(0, TAU)
		var offset := Vector3(cos(rangle), 0, sin(rangle)) * radius

		var clone: Node = enemy.instantiate()
		count += 1
		add_sibling(clone)
		clone.position = self.position + offset
		clone.tree_exiting.connect(uncount)


func uncount() -> void:
	count -= 1
