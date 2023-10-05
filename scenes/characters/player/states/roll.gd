extends PlayerBaseState
# Estado do jogador rolando no chão.


# Variables
export(float, 0.1, 5.0, 0.01) var roll_speed := 1.8
export(float, 0.1, 1.0, 0.01) var roll_duration := 0.3
export(float, 0.1, 1.0, 0.01) var roll_delay := 0.2
export(NodePath) var state_idle: NodePath
export(NodePath) var state_fall: NodePath

var _is_rolling := false
var _in_delay := false


# State overrides
func enter() -> void:
	if _in_delay:
		return

	get_tree().create_timer(roll_duration, false).connect(
		"timeout", self, "_on_timer_rolling_timeout"
	)
	_is_rolling = true
	_process_visual()
	player.move_speed_multiplier = roll_speed
	player.play_sfx_jump()
	player.play_sfx_swing(0.7)


func exit() -> void:
	player._visual.rotation_degrees.x = 0
	player.move_speed_multiplier = 1.0


func physics_process(_delta: float) -> BaseState:
	if _is_rolling and not _in_delay:
		player.move_weight = player.direction_axis
		return null

	if not player.is_on_floor():
		player.jumps_left -= 1
		return get_state(state_fall)

	return get_state(state_idle)


# Private methods
func _process_visual() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player._visual, "rotation_degrees:x", -360, roll_duration)
	tween.set_parallel(true).tween_property(player._visual, "scale:y", 0.5, roll_duration / 4)
	tween.chain().tween_property(player._visual, "scale:y", 1.0, roll_duration / 4)


# Event handlers
func _on_timer_rolling_timeout() -> void:
	_is_rolling = false

	get_tree().create_timer(roll_delay, false).connect(
		"timeout", self, "_on_timer_delay_timeout"
	)
	_in_delay = true


func _on_timer_delay_timeout() -> void:
	_in_delay = false
