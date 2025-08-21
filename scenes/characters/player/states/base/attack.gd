extends PlayerBaseState
class_name PlayerStateAttack
# Estado base do jogador atacando.


# Variables
@export var attack_duration := 0.2 # (float, 0.1, 1.0, 0.01)
@export var attack_speed := 0.5 # (float, 0.0, 5.0, 0.01)

var _is_attacking := false
var _mesh_material: StandardMaterial3D = null


# State overrides
func enter() -> void:
	var timer := get_tree().create_timer(attack_duration, false)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	_is_attacking = true
	player.move_speed_multiplier = attack_speed
	player.play_sfx_swing()
	player._area_attack.set_deferred("monitoring", true)

	if not player._area_attack.body_entered.is_connected(_on_AreaAttack_body_entered):
		player._area_attack.body_entered.connect(_on_AreaAttack_body_entered, CONNECT_ONE_SHOT)


func exit() -> void:
	player.move_speed_multiplier = 1.0
	player._mesh_attack.visible = false
	player._area_attack.set_deferred("monitoring", false)

	if player._area_attack.body_entered.is_connected(_on_AreaAttack_body_entered):
		player._area_attack.body_entered.disconnect(_on_AreaAttack_body_entered)


func physics_process(_delta: float) -> BaseState:
	if _is_attacking:
		player.move_weight = lerp(player.move_weight, player.direction_axis, 0.2)
		return null

	return null


# Private methods
func _process_visual(mesh_attack_rotation: float) -> void:
	player._mesh_attack.visible = true
	player._mesh_attack.rotation.y = deg_to_rad(0)
	player._mesh_attack.rotation.z = deg_to_rad(mesh_attack_rotation)
	_mesh_material = player._mesh_attack.get_active_material(0)
	_mesh_material.albedo_color.a = 1.0
	create_tween().tween_property(_mesh_material, "albedo_color:a", 0.0, attack_duration)


# Event handlers
func _on_timer_timeout() -> void:
	_is_attacking = false


func _on_AreaAttack_body_entered(body: Node) -> void:
	if body == player:
		return

	if not body.has_method("take_damage"):
		return

	body.take_damage()
	player._area_attack.set_deferred("monitoring", false)
