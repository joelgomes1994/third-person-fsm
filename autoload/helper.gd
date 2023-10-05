extends Node


# Variables
var _hashes := {}


# Public methods
# Toca um efeito sonoro 3D na posição do node.
func play_sfx_3d(node: Spatial, sfx, pitch := 1.0, chance := 100) -> void:
	randomize()

	if int(rand_range(1, 100)) > chance:
		return

	var path := ""

	if typeof(sfx) == TYPE_STRING:
		path = sfx

	elif typeof(sfx) == TYPE_ARRAY and sfx.size():
		var sfx_list: Array = sfx

		if sfx_list.size() == 1:
			path = sfx_list[0]

		else:
			var last_sfx: String = sfx_list[0]

			if not _hashes.has(sfx_list.hash()):
				_hashes[sfx_list.hash()] = last_sfx

			while last_sfx.hash() == _hashes[sfx_list.hash()].hash():
				last_sfx = sfx_list[int(rand_range(0, sfx_list.size()))]

			_hashes[sfx_list.hash()] = last_sfx
			path = last_sfx

	if not path:
		return

	var audio_player := AudioStreamPlayer3D.new()
	node.add_child(audio_player)
	audio_player.pitch_scale = rand_range(pitch - 0.05, pitch + 0.05)
	audio_player.stream = load(path)
	audio_player.play()
	yield(audio_player, "finished")
	audio_player.queue_free()
