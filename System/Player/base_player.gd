extends CharacterBody3D
class_name Player

const ACCELERATION = 30.0
const SPEED: float = 3.8
const UNARMED_SPEED: float = 4.2

@export var controller_id: int = 1
@export var partner: Player
@export var health: int = 12

@export var animator_tree: AnimationTree
var last_direction: Vector2 = Vector2.UP

var is_kbm: bool = false
var viewport: Viewport
var camera: Camera3D
var playback: AnimationNodeStateMachinePlayback
var nav_map: RID

var current_speed: float = SPEED
var damage: int = 1
var swings: int = 0


func _ready() -> void:
	die_debounce = false
	for e in InputMap.action_get_events("P%dLeft" % controller_id):
		if e is InputEventKey:
			is_kbm = true
			break

	if is_kbm:
		viewport = get_viewport()
		camera = viewport.get_camera_3d()

	playback = animator_tree.get("parameters/playback")
	nav_map = NavigationServer3D.get_maps()[0]
	#await get_tree().process_frame
	$Sprite3D.texture.viewport_path = $Sprite3D/Healthbar2D.get_path()
	current_speed = SPEED if held_weapon else UNARMED_SPEED


func _physics_process(delta: float) -> void:
	# Movement direction
	var input_dir := Input.get_vector(
		"P%dLeft" % controller_id,
		"P%dRight" % controller_id,
		"P%dForward" % controller_id,
		"P%dBackward" % controller_id).rotated(-PI/4)
	var direction := Vector3(input_dir.x, 0, input_dir.y)
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * current_speed, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, direction.z * current_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, ACCELERATION * delta)

	# Look direction
	if is_kbm:
		# mouse
		var mouse := viewport.get_mouse_position()
		var ray_start := camera.project_ray_origin(mouse)
		var ray_normal := camera.project_ray_normal(mouse)

		var state := get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.create(ray_start, ray_normal * 1000)
		var result: Dictionary = state.intersect_ray(query)
		if result:
			var point: Vector3 = result["position"]
			var diff: Vector3 = point - global_position
			var y_look: float = Vector2(diff.x, -diff.z).angle() - PI/2
			rotation.y = lerp_angle(rotation.y, y_look, TAU*2*delta)
	else:
		# controller
		var look_dir := Input.get_vector(
			"P%dLookRight" % controller_id,
			"P%dLookLeft" % controller_id,
			"P%dLookForward" % controller_id,
			"P%dLookBackward" % controller_id).rotated(PI/4)
		if look_dir:
			var y_look: float = look_dir.angle() + PI/2
			rotation.y = lerp_angle(rotation.y, y_look, TAU*2*delta)

	animator_tree.set("parameters/Walk/blend_position", input_dir.rotated(rotation.y))

	move_and_slide()


@onready var WEAPON_GRAB_POINT := load("res://System/Player/weapon_grab_point.tscn")
@export var held_weapon: Node3D = null
@onready var attack_recovery: Timer = $AttackRecovery


@onready var swing_sfx: AudioStreamPlayer = $SwingSFX
func sword_attack() -> void:
	swings += 1
	attack_recovery.start(0.125 + swings / 12.0)

	playback.travel("Attack")
	await get_tree().create_timer(0.125).timeout

	swing_sfx.play()
	$SlashParticle.restart()

	for body: Node3D in $Hitbox.get_overlapping_bodies():
		if body is Enemy:
			body.take_damage(damage)
	if swings > 4:
		damage = 1


func throw_weapon() -> void:
	var rand_offset := randf_range(2, 6)
	var rand_angle := randf_range(-PI/2, PI/2)
	var throw_pos := partner.global_position - transform.basis.z.rotated(Vector3.UP, rand_angle) * rand_offset

	var throw_pos_nudged := NavigationServer3D.map_get_closest_point(nav_map, throw_pos)

	current_speed = UNARMED_SPEED
	var grab_zone: Area3D = WEAPON_GRAB_POINT.instantiate()
	grab_zone.position = throw_pos_nudged
	grab_zone.model = held_weapon
	grab_zone.from_player = controller_id
	held_weapon = null
	attack_recovery.stop()

	add_sibling(grab_zone)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("P%dAttack" % controller_id):
		if attack_recovery.is_stopped():
			if held_weapon:
				sword_attack()
			else:
				pass # shove attack
	elif event.is_action_pressed("P%dThrow" % controller_id):
		if held_weapon:
			throw_weapon()
		else:
			pass # dodge?
	elif event.is_action_released("Pause"):
		var clone: Control = pause_screen.instantiate()
		get_tree().root.add_child(clone)
		get_tree().paused = true


func grab_weapon(weapon: Node3D, distance_bonus: bool, refresh_swings: bool) -> void:
	if held_weapon == null:
		held_weapon = weapon
		attack_recovery.stop()
		current_speed = SPEED
		if refresh_swings:
			swings = 0
			playback.travel("Flourish")

		weapon.reparent($HandTemp, false)
		weapon.position = Vector3.ZERO
		weapon.quaternion = Quaternion.IDENTITY

		damage = 2 if distance_bonus else 1


const game_over_transition = preload("res://System/game_over_transition.tscn")
@onready var health_bar: Control = %HealthBar
static var die_debounce: bool = false
func take_damage(amount: int) -> void:
	health -= amount
	health_bar.update_value(health)
	if health <= 0 and !die_debounce:
		# Game over!
		die_debounce = true
		set_physics_process(false)
		set_process_input(false)
		animator_tree.set("parameters/conditions/died", true)
		var clone: Control = game_over_transition.instantiate()
		get_tree().root.add_child(clone)
		#get_tree().paused = true


const pause_screen = preload("res://System/Screens/pause_menu.tscn")
