extends PlayerBaseState
class_name PlayerStateAttack
# Estado base do jogador atacando.


# Variables
export(float, 0.1, 1.0, 0.01) var attack_duration := 0.2
export(float, 0.0, 5.0, 0.01) var attack_speed := 0.5

var _is_attacking := false
var _mesh_material: SpatialMaterial = null


# State overrides
func enter() -> void:
	var timer := get_tree().create_timer(attack_duration, false)
	timer.connect("timeout", self, "_on_timer_timeout")
	_is_attacking = true
	player.move_speed_multiplier = attack_speed
	player.play_sfx_swing()
	player._area_attack.set_deferred("monitoring", true)
	player._area_attack.connect(
		"body_entered", self, "_on_AreaAttack_body_entered", [], Node.CONNECT_ONESHOT
	)


func exit() -> void:
	player.move_speed_multiplier = 1.0
	player._mesh_attack.visible = false
	player._area_attack.set_deferred("monitoring", false)


func physics_process(_delta: float) -> BaseState:
	if _is_attacking:
		player.move_weight = lerp(player.move_weight, player.direction_axis, 0.2)
		return null

	return null


# Private methods
func _process_visual(mesh_attack_rotation: float) -> void:
	player._mesh_attack.visible = true
	player._mesh_attack.rotation.y = deg2rad(0)
	player._mesh_attack.rotation.z = deg2rad(mesh_attack_rotation)
	_mesh_material = player._mesh_attack.get("material/0")
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
