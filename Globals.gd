extends Node

enum Terrain {
	Forest,
	Wheat,
	Grass,
	Mountains,
	Mud,
	Sea,
	Desert,
	Unknown,
}

static var _textures = {
	Terrain.Forest: "res://tiles/forest.png",
	Terrain.Wheat: "res://tiles/wheat.png",
	Terrain.Grass: "res://tiles/grass.png",
	Terrain.Mud: "res://tiles/mud.png",
	Terrain.Mountains: "res://tiles/mountains.png",
	Terrain.Sea: "res://tiles/sea.png",
	Terrain.Desert: "res://tiles/desert.png",
	Terrain.Unknown: "res://tiles/unknown.png",
}
static var _loaded: Dictionary = {}

static func terrain_texture(terrain: Terrain):
	if terrain not in _loaded:
		var file = _textures.get(terrain, 'res://tiles/unknown.png')
		_loaded[terrain] = ResourceLoader.load(file)
	return _loaded[terrain]
