extends Node2D
const TileScene = preload("res://scenes/tile.tscn")
const Terrain = Globals.Terrain

@export var game_scenario: ScenarioPreset
var game = ScenarioData.game

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

var terrain_decks = {}
var deck_numbers = {}
var board_tiles = {}

func dice_rolled(value):
	get_tree().call_group("tiles", "on_dice_rolled", value)

func shuffle_decks():
	"""Takes the game template and generates a set of shuffled decks for a game"""
	terrain_decks = {}
	deck_numbers = {}
	for deck_name in game.decks:
		var current_deck = game.decks[deck_name]
		terrain_decks[deck_name] = current_deck.tiles.duplicate()
		var shuffled = current_deck.get('shuffled', false)
		if shuffled: terrain_decks[deck_name].shuffle()
		deck_numbers[deck_name] = current_deck.get('numbers',[]).duplicate()
		if shuffled: deck_numbers[deck_name].shuffle()

func deal_decks():
	"""Lays out the shuffled decks over the board"""
	board_tiles = {}
	get_tree().call_group("tiles", "queue_free")
	for tile_data in game.map:
		var tile_coords = Vector2i(tile_data[0],tile_data[1])
		var deck_name: String = tile_data[2]
		var current_deck = game.decks[deck_name]
		var tile = TileScene.instantiate()
		tile.position = tile2world(tile_coords)
		var terrain =  terrain_decks[deck_name].pop_back()
		var hidden_deck = current_deck.get('hidden', false)
		var shuffled_deck = current_deck.get('shuffled', false)
		var unnumberedTerrains = current_deck.get('unnumbered', [])
		if terrain == null:
			terrain = Terrain.Desert
		tile.terrain = terrain
		tile.explored = not hidden_deck and not shuffled_deck
		if tile.terrain in unnumberedTerrains:
			tile.dice_value = 0
		else:
			var number = deck_numbers[deck_name].pop_back()
			tile.dice_value = number if number != null else 0
		add_child(tile)
		board_tiles[tile_coords] = tile
		if shuffled_deck and not hidden_deck:
			tile.flip()

enum FocusLevel {Tile, Side, Vertex}
var focus_level: FocusLevel = FocusLevel.Tile
func focus_cycle(forward: bool = true):
	var levels: Array = FocusLevel.values()
	var previous: int = levels.find(focus_level)
	focus_level = levels[clamp(previous+(+1 if forward else -1), 0, len(levels)-1)]
	if previous != focus_level:
		focus_side = HexSide.Top
		focus_vertex = HexVertex.TopRight
	update_focus()

var focus_tile: Vector2i = Vector2i.ZERO
func move_focus_tile(side: HexSide):
	var new_pos = tile_at_side(focus_tile, side)
	if new_pos not in board_tiles:
		return
	focus_tile = new_pos
	update_focus()

var focus_side: HexSide = HexSide.Top
func move_focus_side(forward: bool):
	var sides: Array = HexSide.values()
	var previous: int = sides.find(focus_side)
	var movement = 1 if forward else -1
	focus_side = sides[(previous+movement)%len(sides)]
	update_focus()

var focus_vertex: HexVertex = HexVertex.TopRight
func move_focus_vertex(forward: bool):
	var vertexes: Array = HexVertex.values()
	var previous: int = vertexes.find(focus_vertex)
	var movement = 1 if forward else -1
	focus_vertex = vertexes[(previous+movement)%len(vertexes)]
	update_focus()

func update_focus():
	match focus_level:
		FocusLevel.Tile:
			$Marker2D.position = tile2world(focus_tile)
		FocusLevel.Side:
			$Marker2D.position = side_coords(focus_tile, focus_side)
		FocusLevel.Vertex:
			$Marker2D.position = vertex_coords(focus_tile, focus_vertex)

func _ready():
	shuffle_decks()
	deal_decks()
	$Marker2D.position = tile2world(focus_tile)

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
			KEY_ENTER:
				return focus_cycle(true)
			KEY_ESCAPE:
				return focus_cycle(false)
			KEY_UP:
				match focus_level:
					FocusLevel.Tile: return move_focus_tile(HexSide.Top)
					FocusLevel.Side: return move_focus_side(true)
					FocusLevel.Vertex: return move_focus_vertex(true)
			KEY_DOWN:
				match focus_level:
					FocusLevel.Tile: return move_focus_tile(HexSide.Bottom)
					FocusLevel.Side: return move_focus_side(false)
					FocusLevel.Vertex: return move_focus_vertex(false)
			KEY_RIGHT:
				match focus_level:
					FocusLevel.Tile: return move_focus_tile(HexSide.TopRight)
					FocusLevel.Side: return move_focus_side(true)
					FocusLevel.Vertex: return move_focus_vertex(true)
			KEY_LEFT:
				match focus_level:
					FocusLevel.Tile: return move_focus_tile(HexSide.BottomLeft)
					FocusLevel.Side: return move_focus_side(false)
					FocusLevel.Vertex: return move_focus_vertex(false)
			KEY_HOME:
				match focus_level:
					FocusLevel.Tile: return move_focus_tile(HexSide.TopLeft)
					FocusLevel.Side: return move_focus_side(true)
					FocusLevel.Vertex: return move_focus_vertex(true)
			KEY_END:
				match focus_level:
					FocusLevel.Tile: return move_focus_tile(HexSide.BottomLeft)
					FocusLevel.Side: return move_focus_side(false)
					FocusLevel.Vertex: return move_focus_vertex(false)
			KEY_PAGEDOWN:
				match focus_level:
					FocusLevel.Tile: return move_focus_tile(HexSide.BottomRight)
					FocusLevel.Side: return move_focus_side(false)
					FocusLevel.Vertex: return move_focus_vertex(false)
			KEY_PAGEUP:
				match focus_level:
					FocusLevel.Tile: return move_focus_tile(HexSide.TopRight)
					FocusLevel.Side: return move_focus_side(true)
					FocusLevel.Vertex: return move_focus_vertex(true)
