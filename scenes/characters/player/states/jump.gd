extends PlayerStateMove
# Estado do jogador pulando.


# Variables
export(float, 0.0, 100.0, 0.1) var jump_force := 10.0
export(NodePath) var state_fall: NodePath
export(NodePath) var state_attack: NodePath


# State overrides
func enter() -> void:
	player.move_gravity = jump_force
	player.move_snap = Vector3.ZERO
	player.jumps_left -= 1
	player.play_sfx_jump()
	player.play_sfx_swing(0.8)


func physics_process(delta: float) -> BaseState:
	.physics_process(delta)

	if player.jumps_left and Input.is_action_just_pressed("jump"):
		return self

	if Input.is_action_just_pressed("attack"):
		return get_state(state_attack)

	if player.move_gravity > 0.0:
		return null

	return get_state(state_fall)
