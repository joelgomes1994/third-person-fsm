extends Node
class_name BaseStateManager


# Signals
signal state_entered(state)
signal state_exited(state)


# Variables
export(NodePath) var owner_object: NodePath
export(NodePath) var initial_state: NodePath
var object: Node
var current_state: BaseState


# Built-in overrides
func _init() -> void:
	connect("child_entered_tree", self, "_on_child_entered_tree")


func _on_child_entered_tree(node: Node) -> void:
	_set_owner_object(node)


func _ready() -> void:
	_set_initial_state()


func _input(event: InputEvent) -> void:
	if not is_state_valid():
		return

	_handle_new_state(current_state.input(event))


func _unhandled_input(event: InputEvent) -> void:
	if not is_state_valid():
		return

	_handle_new_state(current_state.unhandled_input(event))


func _process(delta: float) -> void:
	if not is_state_valid():
		return

	_handle_new_state(current_state.process(delta))


func _physics_process(delta: float) -> void:
	if not is_state_valid():
		return

	_handle_new_state(current_state.physics_process(delta))


# Public methods
func is_state_valid() -> bool:
	return owner_object and initial_state


# Private methods
func _set_owner_object(node: Node = null) -> void:
	if not owner_object:
		push_warning("You must set owner_object")
		return

	if not object:
		object = get_node(owner_object)

	if node:
		node.object = object


func _set_initial_state() -> void:
	if not initial_state:
		push_warning("You must set initial_state")
		return

	_handle_new_state(get_node(initial_state))


func _handle_new_state(new_state: BaseState) -> void:
	if not new_state:
		return

	if current_state:
		current_state.exit()
		emit_signal("state_exited", current_state)

	current_state = new_state
	new_state.enter()
	emit_signal("state_entered", current_state)
