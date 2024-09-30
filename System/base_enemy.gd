extends CharacterBody3D
class_name Enemy

const SPEED = 4.0

@export var health: int = 2
@export var animator_tree: AnimationTree


var target: Player
func _ready() -> void:
	if target == null:
		var players := get_tree().get_nodes_in_group("Player")
		target = players.pick_random()


@onready var chillout: Timer = $Chillout
@onready var attack_recovery: Timer = $AttackRecovery
func attack() -> void:
	for body: Player in $Hitbox.get_overlapping_bodies():
		body.take_damage(1)
		break

	animator_tree.set("parameters/conditions/walking", false)
	animator_tree.set("parameters/conditions/attacking", true)
	attack_recovery.start()

	await get_tree().create_timer(0.2).timeout
	animator_tree.set("parameters/conditions/attacking", false)


func _physics_process(delta: float) -> void:
	if attack_recovery.is_stopped() and chillout.is_stopped():
		var diff := target.global_position - self.global_position
		var distance := diff.length()
		if distance < 1.2:
			attack()
		elif distance > 30:
			chillout.start()
		else:
			var direction := diff / distance
			direction.y = -2.0
			look_at(target.global_position)
			velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector3.ZERO, SPEED * 2 * delta)

	move_and_slide()


func take_damage(amount: int) -> void:
	health -= amount
	$HitFlash.play("hitflash")

	if health <= 0:
		self.queue_free()


func _on_attack_recovery_timeout() -> void:
	animator_tree.set("parameters/conditions/walking", true)


func _on_chillout_timeout() -> void:
	$Walkstop.start(randf_range(3, 8))


func _on_walkstop_timeout() -> void:
	chillout.start(randf_range(4, 11))
