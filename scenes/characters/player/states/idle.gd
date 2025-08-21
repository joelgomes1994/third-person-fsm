extends PlayerStateMove
# Estado do jogador parado.


# Variables
@export var state_coyote: NodePath
@export var state_run: NodePath
@export var state_jump: NodePath
@export var state_attack: NodePath


# State overrides
func physics_process(delta: float) -> BaseState:
	super.physics_process(delta)

	if not player.is_on_floor():
		return get_state(state_coyote)

	if object.move_axis.length():
		return get_state(state_run)

	if Input.is_action_just_pressed("jump"):
		return get_state(state_jump)

	if Input.is_action_just_pressed("attack"):
		return get_state(state_attack)

	return null
