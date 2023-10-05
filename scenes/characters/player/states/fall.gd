extends PlayerStateMove
class_name PlayerStateFall
# Estado do jogador caindo.


# Variables
export(NodePath) var state_idle: NodePath
export(NodePath) var state_run: NodePath
export(NodePath) var state_jump: NodePath
export(NodePath) var state_attack: NodePath


# State overrides
func physics_process(delta: float) -> BaseState:
	.physics_process(delta)

	if player.jumps_left and Input.is_action_just_pressed("jump"):
		return get_state(state_jump)

	if Input.is_action_just_pressed("attack"):
		return get_state(state_attack)

	if not player.is_on_floor():
		return null

	if player.move_axis.length():
		return get_state(state_run)

	return get_state(state_idle)
