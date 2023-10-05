extends PlayerStateAttack
# Estado do jogador atacando enquanto está no ar.


# Variables
export(NodePath) var state_fall: NodePath


# State overrides
func enter() -> void:
	.enter()
	_process_visual(-45)
	player.play_sfx_attack()


func physics_process(delta: float) -> BaseState:
	.physics_process(delta)

	if _is_attacking:
		return null

	return get_state(state_fall)
