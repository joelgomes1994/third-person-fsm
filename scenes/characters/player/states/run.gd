extends PlayerStateMove
# Estado do jogador correndo.


# Variables
export(NodePath) var state_coyote: NodePath
export(NodePath) var state_idle: NodePath
export(NodePath) var state_jump: NodePath
export(NodePath) var state_roll: NodePath
export(NodePath) var state_attack: NodePath


# State overrides
func physics_process(delta: float) -> BaseState:
	.physics_process(delta)

	if not player.is_on_floor():
		return get_state(state_coyote)

	if not object.move_axis.length():
		return get_state(state_idle)

	if Input.is_action_just_pressed("jump"):
		return get_state(state_jump)

	if Input.is_action_just_pressed("attack"):
		return get_state(state_attack)

	if Input.is_action_just_pressed("roll"):
		return get_state(state_roll)

	return null

