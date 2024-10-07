extends Player

@export var path: Path3D
@onready var enemy_zone := $CPUEnemyZone as Area3D
@onready var hold_throw := $HoldThrow as Timer

@export var end_goal: Node3D

var last_thrower: bool = false
var total_distance: float

func _ready() -> void:
	super._ready()
	set_process_input(false)
	total_distance = partner.global_position.distance_to(end_goal.global_position)


func _physics_process(_delta: float) -> void:
	var sword_safe: bool = held_weapon or partner.held_weapon
	last_thrower = partner.held_weapon == null and last_thrower

	# if not sword on ground
	var dir: Vector3
	if last_thrower or sword_safe:
		var partner_ratio: float = 1.0 - partner.global_position.distance_to(end_goal.global_position) / total_distance
		partner_ratio *= path.curve.point_count

		var partnerd_path: Vector3 = path.curve.samplef(partner_ratio)
		partnerd_path = path.to_global(partnerd_path)
		partnerd_path.y = 0
		var flat_position := global_position
		flat_position.y = 0

		dir = (partnerd_path - flat_position).limit_length(1.0)
		# if held sword and enemy in zone: attack
		if held_weapon:
			if enemy_zone.has_overlapping_bodies():
				for enemy in enemy_zone.get_overlapping_bodies():
					var look: Vector3 = enemy.global_position
					look.y = self.global_position.y
					look_at(look)
					break

				if attack_recovery.is_stopped():
					sword_attack()
			elif attack_recovery.is_stopped() and hold_throw.is_stopped():
				throw_weapon()
				last_thrower = true

	else:
		var grab_point := get_parent().get_node_or_null("WeaponGrabPoint") as Node3D
		if grab_point:
			var diff: Vector3 = grab_point.global_position - global_position
			dir = diff.limit_length(1.0)

	velocity = dir * current_speed

	var blendable_dir := Vector2(dir.x, dir.z)
	animator_tree.set("parameters/Walk/blend_position", blendable_dir.rotated(rotation.y))

	move_and_slide()


func grab_weapon(weapon: Node3D, distance_bonus: bool, refresh_swings: bool) -> void:
	super.grab_weapon(weapon, distance_bonus, refresh_swings)
	attack_recovery.start()
	hold_throw.start()
