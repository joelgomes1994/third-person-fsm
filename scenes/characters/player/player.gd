extends CharacterBody3D
class_name Player
# Classe principal do jogador.
# A lógica de suas ações é delegada aos seus respectivos estados.


# Enums
enum ControllerLook {
	MOUSE,
	JOYPAD,
}


# Constants
const SFX_BASE := "res://scenes/characters/player/sfx/"
const SFX_ATTACK_01 := SFX_BASE + "attack_01.wav"
const SFX_ATTACK_02 := SFX_BASE + "attack_02.wav"
const SFX_ATTACK_03 := SFX_BASE + "attack_03.wav"
const SFX_ATTACK_04 := SFX_BASE + "attack_04.wav"
const SFX_JUMP_01 := SFX_BASE + "jump_01.wav"
const SFX_JUMP_02 := SFX_BASE + "jump_02.wav"
const SFX_JUMP_03 := SFX_BASE + "jump_03.wav"
const SFX_SWING_01 := SFX_BASE + "swing_01.wav"
const SFX_SWING_02 := SFX_BASE + "swing_02.wav"
const SFX_SWING_03 := SFX_BASE + "swing_03.wav"
const SFX_SWING_04 := SFX_BASE + "swing_04.wav"
const SFX_SWING_05 := SFX_BASE + "swing_05.wav"


# Variables
@export var jump_times := 1 # (int, 1, 5, 1)
@export var gravity_force := 0.5 # (float, 0.0, 2.0, 0.01)
@export var move_speed := 5.0 # (float, 0.0, 10.0, 0.1)
@export var intertia_factor := 0.15 # (float, 0.0, 1.0, 0.01)
@export var look_sensitivity := 80.0 # (float, 0.0, 200.0, 0.1)
@export var look_invert_x := 1 # (int, -1, 1, 2)
@export var look_invert_y := -1 # (int, -1, 1, 2)
@export var camera_min_angle := -15.0 # (float, -90.0, 90.0, 0.1)
@export var camera_max_angle := 80.0 # (float, -90.0, 90.0, 0.1)
@export var target_distance_radius := 10.0 # (float, 0.5, 20.0, 0.1)

var input_move_axis := Vector2.ZERO
var input_look_axis := Vector2.ZERO
var input_target_lock := 0.0
var jumps_left := jump_times: set = _set_jumps_left
var direction_axis := Vector2.UP
var move_axis := Vector2.ZERO
var move_speed_multiplier := 1.0
var move_weight := Vector2.ZERO
var move_gravity := 0.0
var move_snap := Vector3.ZERO
var controller: int = ControllerLook.MOUSE
var target_character: Node3D

@onready var _state_manager: BaseStateManager = find_child("StateManager")
@onready var _visual: Node3D = find_child("Visual")
@onready var _mesh_attack: MeshInstance3D = find_child("MeshAttack")
@onready var _camera: Camera3D = find_child("Camera3D")
@onready var _camera_axis: Marker3D = find_child("CameraAxis")
@onready var _camera_origin: Marker3D = find_child("CameraOrigin")
@onready var _camera_smooth: Marker3D = find_child("CameraSmooth")
@onready var _camera_ray_cast: RayCast3D = find_child("CameraRayCast")
@onready var _mesh_direction: MeshInstance3D = find_child("MeshDirection")
@onready var _area_attack: Area3D = find_child("AreaAttack")
@onready var _area_target: Area3D = find_child("AreaTarget")
@onready var _texture_rect_target: TextureRect = find_child("TextureRectTarget")


# Setters and getters
func _set_jumps_left(value: int) -> void:
	jumps_left = int(max(value, 0))


# Built-in overrides
func _ready() -> void:
	_camera_axis.set_as_top_level(true)
	_camera_smooth.set_as_top_level(true)
	_mesh_direction.set_as_top_level(true)
	(_area_target.get_node("CollisionShape3D").shape as SphereShape3D).radius = target_distance_radius

	var tween := create_tween().set_loops()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		_texture_rect_target, "self_modulate:a", 0.5, 0.5
	)
	tween.tween_property(
		_texture_rect_target, "self_modulate:a", 0.8, 0.5
	)

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion and event.axis_value > 0.1:
		controller = ControllerLook.JOYPAD
	elif event is InputEventMouseMotion and event.velocity.length() > 1:
		controller = ControllerLook.MOUSE


func _physics_process(delta: float) -> void:
	_process_move(delta)
	_process_visual(delta)
	_process_camera(delta)
	_process_target(delta)


# Public methods
# Toca som aleatório de voz de pulo.
func play_sfx_jump(pitch := 1.0) -> void:
	var sfx := [
		SFX_JUMP_01,
		SFX_JUMP_02,
		SFX_JUMP_03,
	]
	GameHelper.play_sfx_3d(self, sfx, pitch, 40)


# Toca som aleatório de voz de ataque.
func play_sfx_attack(pitch := 1.0) -> void:
	var sfx := [
		SFX_ATTACK_02,
		SFX_ATTACK_03,
		SFX_ATTACK_04,
	]
	GameHelper.play_sfx_3d(self, sfx, pitch, 40)


# Toca som aleatório de movimento rápido do ar.
func play_sfx_swing(pitch := 1.0) -> void:
	var sfx := [
		SFX_SWING_01,
		SFX_SWING_02,
		SFX_SWING_03,
		SFX_SWING_04,
		SFX_SWING_05,
	]
	GameHelper.play_sfx_3d(self, sfx, pitch)


# Private methods
# Atualiza as malhas visuais de acordo com o estado.
func _process_visual(_delta: float) -> void:
	var target_vec: Vector3 = global_position + _get_axis_offset(move_weight)
	var interp_vec: Vector3 = lerp(global_position, target_vec, 0.01)

	if target_character:
		var raw_position := _camera.unproject_position(target_character.global_position)
		var viewport_size := get_viewport().get_visible_rect().size
		var rect_center := _texture_rect_target.size / 2

		if _camera.is_position_behind(target_character.global_position):
			raw_position.y = viewport_size.y * 2

		if raw_position.x - rect_center.x < 0 or raw_position.x > viewport_size.x:
			_texture_rect_target.rotation = 90
			_texture_rect_target.flip_v = raw_position.x > viewport_size.x
		else:
			_texture_rect_target.flip_v = raw_position.y - rect_center.y < 0.0
			_texture_rect_target.rotation = 0

		_texture_rect_target.visible = true
		_texture_rect_target.modulate = Color.RED if input_target_lock > 0.1 else Color.WHITE

		_texture_rect_target.position = lerp(_texture_rect_target.position, Vector2(
			clamp(
				raw_position.x,
				rect_center.x,
				viewport_size.x - rect_center.x
			) - rect_center.x,
			clamp(
				raw_position.y - 100,
				rect_center.y,
				viewport_size.y - rect_center.y
			) - rect_center.y
		), 0.5)
	else:
		_texture_rect_target.visible = false

	if move_weight.length() > 0.1:
		look_at(interp_vec, Vector3.UP)

	_mesh_direction.global_position = target_vec


# Processa a gravidade e movimentação do jogador seguindo os eixos do controle.
func _process_move(_delta: float) -> void:
	var move_vec: Vector2 = move_weight * move_speed * move_speed_multiplier
	var translation_vec := Vector3(-move_vec.x, move_gravity, move_vec.y)

	set_velocity(translation_vec)
	# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `move_snap`
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()

	move_snap = -get_floor_normal() if is_on_floor() else Vector3.ZERO
	move_weight = lerp(move_weight, move_axis, intertia_factor)

	if move_axis.length():
		direction_axis = move_axis.normalized()

	if is_on_floor():
		jumps_left = jump_times
		move_gravity = 0.0
	else:
		move_gravity = move_gravity - gravity_force

	if is_on_ceiling() and move_gravity > 0.0:
		move_gravity = -1.0


# Processa a movimentação e suavização da câmera.
func _process_camera(delta: float) -> void:
	input_look_axis = Input.get_vector("look_left", "look_right", "look_down", "look_up")

	var viewport_center := (get_viewport().get_visible_rect().size / 2).floor()
	var mouse_offset := get_viewport().get_mouse_position() / viewport_center - Vector2(1, 1) \
		if not input_look_axis.length() else input_look_axis * 0.04 * Vector2(look_invert_x, look_invert_y)

	get_viewport().warp_mouse(viewport_center)

	var mouse_rotation_x := -mouse_offset.x * delta * look_sensitivity
	var mouse_rotation_y := mouse_offset.y * delta * look_sensitivity
	var target_vec: Vector3 = global_position + _get_axis_offset(move_weight)

	_camera_axis.global_position = lerp(global_position, target_vec, 0.1)

	input_target_lock = Input.get_action_strength("target_lock")

	if target_character and input_target_lock > 0.1:
		var target_char_pos_2d := Vector2(target_character.position.x, target_character.position.z)
		var cam_axis_pos_2d := Vector2(_camera_axis.position.x, _camera_axis.position.z)

		if cam_axis_pos_2d.distance_to(target_char_pos_2d) > 0.25:
			var direction := (target_character.position - _camera_axis.position).normalized()
			var angle = lerp_angle(_camera_axis.rotation.y, atan2(direction.x, direction.z), 0.075)
			_camera_axis.rotation.y = angle
	else:
		_camera_axis.rotation.y += mouse_rotation_x

	_camera_axis.rotation.x = clamp(
		_camera_axis.rotation.x + mouse_rotation_y,
		deg_to_rad(camera_min_angle), deg_to_rad(camera_max_angle)
	)

	if input_move_axis.length() and controller == ControllerLook.JOYPAD:
		_camera_axis.rotation.y -= input_move_axis.x * 1.5 * delta

	_camera_smooth.global_transform = _camera_smooth.global_transform.interpolate_with(
		_camera_axis.global_transform, 0.2
	)

	_camera_collision()


# Processa a seleção manual de alvo atual.
func _process_target(_delta: float) -> void:
	var bodies := _area_target.get_overlapping_bodies()

	if not Input.is_action_pressed("target_lock"):
		for _body in bodies:
			var body: Node3D = _body

			if not target_character:
				target_character = body
				continue

			var current_distance := global_position.distance_to(target_character.global_position)

			if current_distance > global_position.distance_to(body.global_position):
				target_character = body

	if not bodies.size() or not Input.is_action_just_pressed("target_change"):
		return

	for i in bodies.size():
		var body: Node3D = bodies[i]

		if body != target_character:
			continue

		target_character = bodies[wrapi(i + 1, 0, bodies.size())]
		break


# Processa a lógica de colisão de câmera.
func _camera_collision() -> void:
	_camera_ray_cast.target_position.z = -_camera_ray_cast.global_position.distance_to(_camera_origin.global_position)
	_camera.global_position = _camera_ray_cast.get_collision_point() \
		if _camera_ray_cast.is_colliding() \
		else _camera_origin.global_position

	_camera.position.z += 0.2


# Helper methods
# Converte o Vector2 de entrada de controle para a direção alvo em Vector3.
static func _get_axis_offset(axis_vec: Vector2) -> Vector3:
	return Vector3(-axis_vec.x, 0.0, axis_vec.y)


# Seleciona ou remove o personagem alvo atual.
func _set_target_character() -> void:
	var bodies := _area_target.get_overlapping_bodies()

	if not bodies.size() or not target_character in bodies:
		target_character = null

	if not target_character and bodies.size():
		target_character = bodies[0]


# Event handlers
# Atualizar o texto de debug quando um estado entrar na cena.
func _on_StateManager_state_entered(state: BaseState) -> void:
	$LabelDebug.text = state.name


func _on_AreaTarget_body_entered(body: Node) -> void:
	_set_target_character()
	prints(target_character, body, "entered")


func _on_AreaTarget_body_exited(body: Node) -> void:
	_set_target_character()
	prints(target_character, body, "exited")
