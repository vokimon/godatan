extends Node2D
class_name Board
const TileScene = preload("res://scenes/tile.tscn")
const Terrain = Globals.Terrain

@export_category("Board")
@export var scenario: ScenarioPreset = preload("res://data/scenario_basic.tres")

var decks = {}
var terrain_decks = {}
var number_decks = {}
var port_decks = {}

var board_tiles = {}

func dice_rolled(value):
	get_tree().call_group("tiles", "on_dice_rolled", value)

func shuffle_decks():
	"""Takes the game template and generates a set of shuffled decks for a game"""
	decks = {}
	terrain_decks = {}
	number_decks = {}
	port_decks = {}
	for current_deck in scenario.decks:
		var deck_name = current_deck.name
		decks[deck_name] = current_deck
		terrain_decks[deck_name] = current_deck.tiles.duplicate()
		var shuffled = current_deck.shuffled
		if shuffled: terrain_decks[deck_name].shuffle()
		number_decks[deck_name] = current_deck.numbers.duplicate()
		if shuffled: number_decks[deck_name].shuffle()
		port_decks[deck_name] = current_deck.port_resources.duplicate()
		if current_deck.ports_shuffled: port_decks[deck_name].shuffle()

func deal_decks():
	"""Lays out the shuffled decks over the board"""
	board_tiles = {}
	get_tree().call_group("tiles", "queue_free")
	for tile_coords: Vector2i in scenario.map:
		var deck_name: String = scenario.map[tile_coords]
		var current_deck = decks[deck_name]
		var tile = TileScene.instantiate()
		tile.position = Hex.tile2world(tile_coords)
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
	for port_location in scenario.port_locations:
		var resource:  Globals.ResourceType = Board.deck_deal(port_decks, "sea", Globals.ResourceType.Nothing)
		add_port_overlay(port_location.tile, port_location.side, resource)

func add_port_overlay(tile_pos: Vector2i, side: Hex.Side, resource: Globals.ResourceType):
		var portMarker = Sprite2D.new()
		portMarker.texture = load("res://tiles/harbour.svg")
		portMarker.rotate(deg_to_rad(side))
		var portSpeciality = Sprite2D.new()
		portSpeciality.texture = Globals.resource_texture(resource)
		portSpeciality.scale = Vector2(0.3,0.3)
		portSpeciality.rotate(deg_to_rad(side+180))
		var tile: RigidBody2D = board_tiles[tile_pos]
		add_port_overlay
		tile.add_child(portMarker)
		tile.add_child(portSpeciality)

static func deck_deal(deck_type, deck_name, default):
	if deck_name not in deck_type:
		return default
	var selected = deck_type[deck_name].pop_back()
	if selected == null: return default
	return selected
		

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
