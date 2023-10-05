extends PlayerStateAttack
# Estado do jogador atacando no chão.


# Variables
export(NodePath) var state_idle: NodePath
export(NodePath) var state_run: NodePath
export(NodePath) var state_jump: NodePath


# State overrides
func enter() -> void:
	.enter()
	_process_visual(0)
	player.play_sfx_attack()


func physics_process(delta: float) -> BaseState:
	.physics_process(delta)

	if _is_attacking:
		return null

	if not player.move_axis.length():
		return get_state(state_idle)

	if player.move_axis.length():
		return get_state(state_run)

	if Input.is_action_just_pressed("jump"):
		return get_state(state_jump)

	return null
