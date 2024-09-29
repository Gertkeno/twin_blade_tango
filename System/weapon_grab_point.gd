extends Area3D

var from_player: int = 1 # Must be set before _ready

var model_start: Vector3
var model: Node3D # Must be set before _ready

@onready var path3d: Path3D = $Path3D
@onready var path_follow: PathFollow3D = $Path3D/PathFollow3D
var bake_length: float
var distance_bonus: bool = false

const curve_height: float = 4.0
const distance_bonus_minimum = 13.0
const throw_speed: float = 7.0
const early_catch_distance: float = 1.0


func _ready() -> void:
	var curve := path3d.curve

	model_start = model.global_position
	curve.add_point(model_start, Vector3.ZERO, Vector3.UP)
	var midpoint := (model_start + self.global_position) / 2
	midpoint.y += curve_height
	var diff := self.global_position - model_start
	var curve_min := minf(diff.length() / 2, 4)
	var dir := diff.normalized() * curve_min
	curve.add_point(midpoint, -dir, dir)
	curve.add_point(self.global_position + Vector3.UP, Vector3.UP, Vector3.ZERO)

	bake_length = curve.get_baked_length()
	model.reparent(path_follow, false)
	model.position = Vector3.ZERO

	if bake_length > distance_bonus_minimum:
		distance_bonus = true
		$Bonus.emitting = true # more VFX!


func _process(delta: float) -> void:
	path_follow.progress += delta * throw_speed
	model.rotate_x(delta * 1.8 * TAU)

	if !monitoring and path_follow.progress > bake_length - early_catch_distance:
		monitoring = true
		for body in get_overlapping_bodies():
			_on_body_entered(body)
			break

	if path_follow.progress_ratio >= 1.0:
		distance_bonus = false
		$Bonus.emitting = false
		set_process(false)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		var new_weilder: bool = body.controller_id != from_player
		body.grab_weapon(model, distance_bonus and new_weilder, new_weilder)
		self.queue_free()
