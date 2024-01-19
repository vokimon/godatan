extends Node

enum Terrain {
	Unknown,
	Wheat,
	Forest,
	Grass,
	Mountains,
	Mud,
	Sea,
	Desert,
}

static var _textures = {
	Terrain.Unknown: "res://tiles/unknown.png",
	Terrain.Forest: "res://tiles/forest.png",
	Terrain.Wheat: "res://tiles/wheat.png",
	Terrain.Grass: "res://tiles/grass.png",
	Terrain.Mud: "res://tiles/mud.png",
	Terrain.Mountains: "res://tiles/mountains.png",
	Terrain.Sea: "res://tiles/sea.png",
	Terrain.Desert: "res://tiles/desert.png",
}
static var _loaded: Dictionary = {}

static func terrain_texture(terrain: Terrain):
	if terrain not in _loaded:
		var file = _textures.get(terrain, 'res://tiles/unknown.png')
		_loaded[terrain] = ResourceLoader.load(file)
	return _loaded[terrain]

# Resources
enum ResourceType {
	Nothing,
	Wood,
	Grain,
	Sheep,
	Brick,
	Stone,
}
static var _resource_textures = {
	ResourceType.Nothing: "res://tiles/question.svg",
	ResourceType.Wood: "res://tiles/wood.svg",
	ResourceType.Grain: "res://tiles/grain.svg",
	ResourceType.Sheep: "res://tiles/sheep.svg",
	ResourceType.Brick: "res://tiles/brick.svg",
	ResourceType.Stone: "res://tiles/stone.svg",
}
static var _loaded_resource_textures = {}
static func resource_texture(resource: ResourceType):
	if resource not in _loaded_resource_textures:
		var file = _resource_textures.get(resource, 'res://tiles/question.svg')
		_loaded_resource_textures[resource] = ResourceLoader.load(file)
	return _loaded_resource_textures[resource]
