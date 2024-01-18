class_name ScenarioPreset
extends Resource

"""
An scenario preset is a way of laying out the decks of tiles on the board.
"""

const Terrain = Globals.Terrain
@export var name: String = "Untittled"
@export var map: Dictionary = {} # Vector2i -> DeckName
@export var decks: Array[TileDeck] = [] 
@export var player_piece_set: Dictionary = {} # Name -> int

static func load(filename) -> ScenarioPreset:
	return ResourceLoader.load(filename)

func save(filename):
	ResourceSaver.save(self, filename)

static var exported = data_to_resource(
	ScenarioData.game, 'res://data/scenario_exported.tres'
)

static func data_to_resource(data, resource_file):
	var scenario = ScenarioPreset.new()
	scenario.from_data(data)
	scenario.save(resource_file)
	return scenario

func from_data(game):
	name = game.name
	player_piece_set = game.player_piece_set
	map =  {}
	for data in game.map:
		var tile_coords = Vector2i(data[0], data[1])
		map[tile_coords] = data[2]
	decks = []
	for deck_name in game.decks:
		var deck_data = game.decks[deck_name]
		var deck = TileDeck.new()
		deck.name = deck_name
		deck.tiles.clear()
		for tile: Terrain in deck_data.get('tiles', []):
			deck.tiles.append(tile)
		deck.numbers.clear()
		for n in deck_data.get('numbers', []):
			deck.numbers.append(n)
		deck.hidden = deck_data.get('hidden', false)
		deck.shuffled = deck_data.get('shuffled', false)
		deck.unnumbered = [] as Array[Terrain]
		for terrain in deck_data.get('unnumbered', []):
			deck.unnumbered.append(terrain)
		decks.append(deck)
