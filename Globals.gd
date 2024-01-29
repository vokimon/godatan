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
	Terrain.Unknown: "res://images/unknown.png",
	Terrain.Forest: "res://images/forest.png",
	Terrain.Wheat: "res://images/wheat.png",
	Terrain.Grass: "res://images/grass.png",
	Terrain.Mud: "res://images/mud.png",
	Terrain.Mountains: "res://images/mountains.png",
	Terrain.Sea: "res://images/sea.png",
	Terrain.Desert: "res://images/desert.png",
}
static var _loaded: Dictionary = {}

func terrain_texture(terrain: Terrain):
	if terrain not in _loaded:
		var file = _textures.get(terrain, 'res://images/unknown.png')
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
	ResourceType.Nothing: "res://images/question.svg",
	ResourceType.Wood: "res://images/wood.svg",
	ResourceType.Grain: "res://images/grain.svg",
	ResourceType.Sheep: "res://images/sheep.svg",
	ResourceType.Brick: "res://images/brick.svg",
	ResourceType.Stone: "res://images/stone.svg",
}
static var _loaded_resource_textures = {}
func resource_texture(resource: ResourceType):
	if resource not in _loaded_resource_textures:
		var file = _resource_textures.get(resource, 'res://images/question.svg')
		_loaded_resource_textures[resource] = ResourceLoader.load(file)
	return _loaded_resource_textures[resource]
