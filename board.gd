extends Node2D
const TileScene = preload("res://tile.tscn")
const Terrain = Globals.Terrain
const game = {
	"map": [
		# hex-x, hex-y, deck
		[-3, -3, "sea"],
		[-3, -2, "sea"],
		[-3, -1, "sea"],
		[-3, +0, "sea"],
		[-2, -3, "sea"],
		[-2, -2, "land"],
		[-2, -1, "land"],
		[-2, +0, "land"],
		[-2, +1, "sea"],
		[-1, -3, "sea"],
		[-1, -2, "land"],
		[-1, -1, "land"],
		[-1, +0, "land"],
		[-1, +1, "land"],
		[-1, +2, "sea"],
		[+0, -3, "sea"],
		[+0, -2, "land"],
		[+0, -1, "land"],
		[+0, +0, "land"],
		[+0, +1, "land"],
		[+0, +2, "land"],
		[+0, +3, "sea"],
		[+1, -2, "sea"],
		[+1, -1, "land"],
		[+1, +0, "land"],
		[+1, +1, "land"],
		[+1, +2, "land"],
		[+1, +3, "sea"],
		[+2, -1, "sea"],
		[+2, +0, "land"],
		[+2, +1, "land"],
		[+2, +2, "land"],
		[+2, +3, "sea"],
		[+3, +0, "sea"],
		[+3, +1, "sea"],
		[+3, +2, "sea"],
		[+3, +3, "sea"],
		[+4, +0, "sea"],
		[+4, +1, "newworld"],
		[+4, +2, "newworld"],
		[+4, +3, "newworld"],
		[+4, +4, "sea"],
		[+5, +0, "sea"],
		[+5, +1, "newworld"],
		[+5, +2, "newworld"],
		[+5, +3, "newworld"],
		[+5, +4, "newworld"],
		[+5, +5, "sea"],
		[+6, +1, "sea"],
		[+6, +2, "sea"],
		[+6, +3, "sea"],
		[+6, +4, "sea"],
		[+6, +5, "sea"],
	],
	"decks": {
		"sea": {
			"tiles": [
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,

				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
				Terrain.Sea,
			],
		},
		"newworld": {
			"hidden": true,
			"shuffled": true,
			"tiles": [
				Terrain.Forest,
				Terrain.Wheat,
				Terrain.Grass,
				Terrain.Mountains,
				Terrain.Mud,
				Terrain.Sea,
			],
			"numbers": [
				6,5,4,3,2,
				8,9,10,11,12,
			],
			"unnumbered": [
				Terrain.Desert,
				Terrain.Sea,
			]
		},
		"land": {
			"shuffled": true,
			"tiles": [
				Terrain.Desert,
				Terrain.Forest,
				Terrain.Forest,
				Terrain.Forest,
				Terrain.Forest,
				Terrain.Wheat,
				Terrain.Wheat,
				Terrain.Wheat,
				Terrain.Wheat,
				Terrain.Grass,
				Terrain.Grass,
				Terrain.Grass,
				Terrain.Grass,
				Terrain.Mountains,
				Terrain.Mountains,
				Terrain.Mountains,
				Terrain.Mud,
				Terrain.Mud,
				Terrain.Mud,
			],
			"numbers": [
				6,6,5,5,4,4,3,3,2,
				8,8,9,9,10,10,11,11,12,
			],
			"unnumbered": [
				Terrain.Desert,
			]
		}
	}
}
const tile_side = 100
const tile_width = tile_side * 2
const tile_heigth = tile_side * sqrt(3) # 173.20
const tile_margin = 1

func tile2world(x,y):
	return Vector2(
		x * (tile_width * 0.75 + tile_margin),
		y * (tile_heigth + tile_margin) - x * (tile_heigth / 2. + tile_margin / 2.),
	)

var terrain_decks = {}
var deck_numbers = {}

func shuffle_decks():
	for deck_name in game.decks:
		var current_deck = game.decks[deck_name]
		terrain_decks[deck_name] = current_deck.tiles.duplicate()
		var shuffled = current_deck.get('shuffled', false)
		if shuffled: terrain_decks[deck_name].shuffle()
		deck_numbers[deck_name] = current_deck.get('numbers',[]).duplicate()
		if shuffled: deck_numbers[deck_name].shuffle()

func deal_decks():
	for tile_data in game.map:
		var x: int = tile_data[0]
		var y: int = tile_data[1]
		var deck_name: String = tile_data[2]
		var current_deck = game.decks[deck_name]
		var tile = TileScene.instantiate()
		tile.position = tile2world(x,y)
		var terrain =  terrain_decks[deck_name].pop_back()
		var hidden_deck = current_deck.get('hidden', false)
		var shuffled_deck = current_deck.get('shuffled', false)
		var unnumberedTerrains = current_deck.get('unnumbered', [])
		if terrain == null:
			terrain = Globals.Terrain.Desert
		tile.terrain = terrain
		tile.explored = not hidden_deck and not shuffled_deck
		if tile.terrain in unnumberedTerrains:
			tile.dice_value = 0
		else:
			var number = deck_numbers[deck_name].pop_back()
			tile.dice_value = number if number != null else 0
		add_child(tile)

func _ready():
	shuffle_decks()
	deal_decks()

func _process(_delta):
	pass
