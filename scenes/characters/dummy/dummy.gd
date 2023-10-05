extends KinematicBody


# Constants
const SFX_BASE := "res://scenes/characters/dummy/sfx/"
const SFX_HIT := SFX_BASE + "hit.wav"


# Variables
var health := 10

onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")
onready var _label_debug: Label3D = find_node("LabelDebug")


# Built-in overrides
func _ready() -> void:
	_anim_player.play("idle_loop")
	_update_label_debug()


# Public methods
func take_damage() -> void:
	if health == 0:
		return

	health -= 1
	_update_label_debug()

	if _anim_player.is_playing():
		_anim_player.stop()

	GameHelper.play_sfx_3d(self, SFX_HIT)

	if health:
		_anim_player.play("hit", -1, 5)
	else:
		_anim_player.play("die", -1, 1.5)
		set_collision_layer_bit(2, false)
		set_collision_mask_bit(1, false)
		yield(_anim_player, "animation_finished")
		queue_free()


# Private methods
func _update_label_debug() -> void:
	if not health:
		_label_debug.visible = false
		return

	_label_debug.text = "HP:" + str(health)
