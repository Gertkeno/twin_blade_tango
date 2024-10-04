extends Control

@onready var animator: AnimationPlayer = $AnimationPlayer

@onready var lead_label: Label = %Lead/Label
@onready var follow_label: Label = %Follow/Label
@onready var lead_portrait: TextureRect = %LeadPortrait
@onready var follow_portrait: TextureRect = %FollowPortrait

@onready var active_label: Label = lead_label
@onready var active_portrait: TextureRect = lead_portrait
var for_player: int = 1
var prompt_tween: Tween

const main_map = "res://System/white_box.tscn"

const input_strings: PackedStringArray = [
	"P%dLeft",
	"P%dRight",
	"P%dForward",
	"P%dBackward",
	"P%dLookLeft",
	"P%dLookRight",
	"P%dLookForward",
	"P%dLookBackward",
	"P%dAttack",
	"P%dThrow",
]

var used_keyboard: bool = false
var used_controller_id: int = -1

const PULSE_TIME: float = 1.0

func _ready() -> void:
	InputMap.load_from_project_settings()
	prompt_tween = create_tween().set_loops().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	prompt_tween.tween_property(active_label, "self_modulate", Color.TRANSPARENT, PULSE_TIME).from(Color.WHITE)
	prompt_tween.tween_property(active_label, "self_modulate", Color.WHITE, PULSE_TIME).from(Color.TRANSPARENT)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and !event.pressed and !used_keyboard:
		active_label.text = "Keyboard!"
		used_keyboard = true

		for a in input_strings:
			var b: String = a % for_player
			var controller_events: Array[InputEvent] = []
			for e in InputMap.action_get_events(b):
				if e is InputEventJoypadButton or e is InputEventJoypadMotion:
					controller_events.append(e)
			for e in controller_events:
				InputMap.action_erase_event(b, e)

	elif event is InputEventJoypadButton and !event.pressed and event.device != used_controller_id:
		active_label.text = "%s! (%d)" % [Input.get_joy_name(event.device), (event.device + 1)]
		used_controller_id = event.device

		for a in input_strings:
			var b: String = a % for_player
			var keyboard_events: Array[InputEvent] = []
			for e in InputMap.action_get_events(b):
				if e is InputEventKey or e is InputEventMouseButton:
					keyboard_events.append(e)
				elif e is InputEventJoypadButton or e is InputEventJoypadMotion:
					e.device = event.device # remap works?
			for e in keyboard_events:
				InputMap.action_erase_event(b, e)

	else:
		return

	prompt_tween.stop()
	active_portrait.self_modulate = Color.WHITE
	for_player += 1

	active_label.self_modulate = Color.WHITE
	active_label = follow_label
	active_portrait = follow_portrait
	
	if for_player > 2:
		set_process_input(false)
		animator.play("transition")
		ResourceLoader.load_threaded_request(main_map, "PackedScene")
	else:
		active_label.text = "Press a Controller Button"

		prompt_tween = create_tween().set_loops().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		prompt_tween.tween_property(active_label, "self_modulate", Color.TRANSPARENT, PULSE_TIME).from(Color.WHITE)
		prompt_tween.tween_property(active_label, "self_modulate", Color.WHITE, PULSE_TIME).from(Color.TRANSPARENT)


func _on_animation_finished(_anim_name: String) -> void:
	var scene: PackedScene = ResourceLoader.load_threaded_get(main_map)
	get_tree().change_scene_to_packed(scene)
