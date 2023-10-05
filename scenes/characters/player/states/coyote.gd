extends PlayerStateFall
# Estado do coyote time jogador.


# Variables
export(float, 0.0, 1.0, 0.01) var coyote_time_max := 0.2
export(NodePath) var state_fall: NodePath

var _coyote_active := false
var _coyote_time := 0.0


# State overrides
func enter() -> void:
	.enter()
	_coyote_time = 0.0
	_coyote_active = true


func exit() -> void:
	.exit()
	_coyote_active = false


func physics_process(delta: float) -> BaseState:
	var new_state := .physics_process(delta)

	if new_state:
		return new_state

	_coyote_time += delta

	if _coyote_time > coyote_time_max:
		player.jumps_left -= 1
		return get_state(state_fall)

	if Input.is_action_just_pressed("jump"):
		return get_state(state_jump)

	return null
