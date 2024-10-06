extends Camera3D

@export var targets: Array[Node3D]
@export var offset := Vector3(0, 0, 45.0)

@export var size_ratio: float = 1.0
@export var size_minimum: float = 10.0


func _process(_delta: float) -> void:
	var midpoint := Vector3.ZERO

	for t in targets:
		midpoint += t.position
	midpoint /= targets.size()

	var distant: float = midpoint.distance_to(targets[0].position)
	size = lerpf(size, max(size_minimum, distant * size_ratio), 0.08)

	var target: Vector3 = midpoint + (transform.basis * offset)
	position = position.lerp(target, 0.08)

