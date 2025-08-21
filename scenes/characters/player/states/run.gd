extends PlayerStateMove
# Estado do jogador correndo.


# Variables
@export var state_coyote: NodePath
@export var state_idle: NodePath
@export var state_jump: NodePath
@export var state_roll: NodePath
@export var state_attack: NodePath


# State overrides
func physics_process(delta: float) -> BaseState:
	super.physics_process(delta)

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

