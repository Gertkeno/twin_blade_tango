extends Player

@export var path: Path3D
@onready var enemy_zone := $CPUEnemyZone as Area3D

func _ready() -> void:
	super._ready()
	set_process_input(false)


func _physics_process(_delta: float) -> void:
	var sword_safe: bool = held_weapon or partner.held_weapon
	# if not sword on ground
	if sword_safe:
		var parterd_local := path.to_local(partner.global_position)
		var parterd_path_offset: float = path.curve.get_closest_offset(parterd_local)
		var parterd_path: Vector3 = path.curve.sample_baked(parterd_path_offset + 2.0)
		parterd_path = path.to_global(parterd_path)
		parterd_path.y = 0
		var flat_position := global_position
		flat_position.y = 0

		var diff := parterd_path - flat_position

		var dir := diff.limit_length(1.0)
		velocity = dir * current_speed

		var blendable_dir := Vector2(dir.x, dir.z)
		animator_tree.set("parameters/Walk/blend_position", blendable_dir.rotated(rotation.y))


		# if held sword and enemy in zone: attack
	else:
		var grab_point := get_parent().get_node_or_null("WeaponGrabPoint") as Node3D
		if grab_point:
			var diff: Vector3 = grab_point.global_position - global_position
			var dir := diff.limit_length(1.0)

			velocity = dir * current_speed
			# go to sword point
	move_and_slide()


func _on_attack_recovery_timeout() -> void:
	if held_weapon:
		pass
		# attack any nearby enemy
