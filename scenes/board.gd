extends Node2D
class_name Board
const TileScene = preload("res://scenes/tile.tscn")
const Terrain = Globals.Terrain

@export_category("Board")
@export var scenario: ScenarioPreset = preload("res://data/scenario_basic.tres")

const tile_side = 100
const tile_width = tile_side * 2
const tile_heigth = tile_side * sqrt(3) # 173.20
const tile_margin = 0

enum HexSide {
	Top = 0,
	TopRight = +60,
	BottomRight = +120,
	Bottom = 180,
	BottomLeft = -120,
	TopLeft = -60,
}

enum HexVertex {
	TopRight = +30,
	Right = +90,
	BottomRight = +150,
	BottomLeft = -150,
	Left = -90,
	TopLeft = -30,
}

func tile2world(tile_pos: Vector2i) -> Vector2:
	return Vector2(
		tile_pos.x * (tile_width * 0.75 + tile_margin),
		tile_pos.y * (tile_heigth + tile_margin) - tile_pos.x * (tile_heigth / 2. + tile_margin / 2.),
	)

func tile_at_side(from: Vector2i, side: HexSide) -> Vector2i:
	match side:
		HexSide.Top:
			return Vector2i(from.x, from.y-1)
		HexSide.TopRight:
			return Vector2i(from.x+1, from.y)
		HexSide.BottomRight:
			return Vector2i(from.x+1, from.y+1)
		HexSide.Bottom:
			return Vector2i(from.x, from.y+1)
		HexSide.BottomLeft:
			return Vector2i(from.x-1, from.y)
		HexSide.TopLeft:
			return Vector2i(from.x-1, from.y-1)
	return from # Should not return

func side_coords(from: Vector2i, side: HexSide) -> Vector2:
	return tile2world(from) + tile_heigth/2. * Vector2(
		sin(deg_to_rad(side)),
		-cos(deg_to_rad(side)),
	)

func vertex_coords(from: Vector2i, vertex: HexVertex) -> Vector2:
	return tile2world(from) + tile_side * Vector2(
		sin(deg_to_rad(vertex)),
		-cos(deg_to_rad(vertex)),
	)

var decks = {}
var terrain_decks = {}
var number_decks = {}
var board_tiles = {}

func dice_rolled(value):
	get_tree().call_group("tiles", "on_dice_rolled", value)

func shuffle_decks():
	"""Takes the game template and generates a set of shuffled decks for a game"""
	decks = {}
	terrain_decks = {}
	number_decks = {}
	for current_deck in scenario.decks:
		var deck_name = current_deck.name
		decks[deck_name] = current_deck
		terrain_decks[deck_name] = current_deck.tiles.duplicate()
		var shuffled = current_deck.shuffled
		if shuffled: terrain_decks[deck_name].shuffle()
		number_decks[deck_name] = current_deck.numbers.duplicate()
		if shuffled: number_decks[deck_name].shuffle()

func deal_decks():
	"""Lays out the shuffled decks over the board"""
	board_tiles = {}
	get_tree().call_group("tiles", "queue_free")
	for tile_coords: Vector2i in scenario.map:
		var deck_name: String = scenario.map[tile_coords]
		var current_deck = decks[deck_name]
		var tile = TileScene.instantiate()
		tile.position = tile2world(tile_coords)
		var terrain =  terrain_decks[deck_name].pop_back()
		var hidden_deck = current_deck.hidden
		var shuffled_deck = current_deck.shuffled
		var unnumberedTerrains = current_deck.unnumbered
		if terrain == null:
			terrain = Terrain.Desert
		tile.terrain = terrain
		tile.explored = not hidden_deck and not shuffled_deck
		if tile.terrain in unnumberedTerrains:
			tile.dice_value = 0
		else:
			var number = number_decks[deck_name].pop_back()
			tile.dice_value = number if number != null else 0
		add_child(tile)
		board_tiles[tile_coords] = tile
		if shuffled_deck and not hidden_deck:
			tile.flip()

func _ready():
	shuffle_decks()
	deal_decks()

func _process(_delta):
	pass

func _input(event):
	if event is InputEventKey:
		if event.is_pressed(): return
		match event.keycode:
			KEY_R:
				shuffle_decks()
				deal_decks()
				return
