extends PlayerBaseState
class_name PlayerStateMove
# Estado base de movimentação do jogador, detectando controles.


# State overrides
func input(_event: InputEvent) -> BaseState:
	player.input_move_axis = Input.get_vector(
		"move_left", "move_right",
		"move_down", "move_up"
	)
	player.move_axis = player.input_move_axis.rotated(
		player._camera_axis.global_rotation.y
	)

	return null
