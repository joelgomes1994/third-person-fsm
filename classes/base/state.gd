extends Node
class_name BaseState


# Variables
var object: Node setget _set_object


# Setters
func _set_object(value: Node) -> void:
	object = value


# Virtual methods
# Executado ao entrar no estado.
func enter() -> void:
	pass


# Executado ao sair do estado.
func exit() -> void:
	pass


# Executado em cada input do usuário.
func input(_event: InputEvent) -> BaseState:
	return null


# Executado em cada input não manipulado do usuário.
func unhandled_input(_event: InputEvent) -> BaseState:
	return null


# Executado a cada quadro do jogo.
func process(_delta: float) -> BaseState:
	return null


# Executado a cada quadro em sincronia com a física do jogo.
func physics_process(_delta: float) -> BaseState:
	return null


# Resolve o node de estado a partir de seu node path.
func get_state(node: NodePath) -> BaseState:
	if not node:
		push_warning("Node path not set at state: " + name)
		return null

	return get_node(node) as BaseState
