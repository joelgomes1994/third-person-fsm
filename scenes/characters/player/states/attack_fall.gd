extends PlayerStateAttack
# Estado do jogador atacando ao cair.


# Variables
export(NodePath) var state_idle: NodePath


# State overrides
func enter() -> void:
	.enter()
	_process_visual(90)
	GameHelper.play_sfx_3d(player, player.SFX_ATTACK_01)


func physics_process(delta: float) -> BaseState:
	.physics_process(delta)

	player.move_gravity -= player.gravity_force

	if not player.is_on_floor():
		return null

	return get_state(state_idle)
