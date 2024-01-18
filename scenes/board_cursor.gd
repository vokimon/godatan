class_name BoardCursor
extends Marker2D

"""
A BoardCursor is a keyboard controled cursor to navigate among tiles
and within tile hot spots (sides and corners).
"""
# TODO: Fully decouple from Board

const HexSide = Hex.HexSide
const HexVertex = Hex.HexVertex

enum FocusLevel { Tile, Side, Vertex }
enum CursorMode { Tile, SubTile }

@export_category("Board Cursor")
@export var cursor_mode: CursorMode = CursorMode.Tile
@export var focus_tile: Vector2i = Vector2i.ZERO
@export var focus_subtile: int = 0
@export var focus_level: FocusLevel:
	get:
		if cursor_mode == CursorMode.Tile: return FocusLevel.Tile
		if focus_subtile & 1: return FocusLevel.Vertex
		return FocusLevel.Side

const subtiles = [
	HexSide.Top,
	HexVertex.TopRight,
	HexSide.TopRight,
	HexVertex.Right,
	HexSide.BottomRight,
	HexVertex.BottomRight,
	HexSide.Bottom,
	HexVertex.BottomLeft,
	HexSide.BottomLeft,
	HexVertex.Left,
	HexSide.TopLeft,
	HexVertex.TopLeft,
]

func enter_subtile():
	if cursor_mode == CursorMode.SubTile: return
	cursor_mode = CursorMode.SubTile
	focus_subtile = 0
	update_focus()

func exit_subtile():
	if cursor_mode == CursorMode.Tile: return
	cursor_mode = CursorMode.Tile
	update_focus()

func move_focus_intile(forward: bool):
	var movement = 1 if forward else -1
	focus_subtile = (focus_subtile+movement)%len(subtiles)
	update_focus()

func move_focus_tile(side: HexSide):
	var new_pos = Hex.tile_at_side(focus_tile, side)
	if new_pos not in get_parent().board_tiles:
		return
	focus_tile = new_pos
	update_focus()

func update_focus():
	match focus_level:
		FocusLevel.Tile:
			position = Hex.tile2world(focus_tile)
		FocusLevel.Side:
			var focus_side = subtiles[focus_subtile]
			position = Hex.side_coords(focus_tile, focus_side)
		FocusLevel.Vertex:
			var focus_vertex = subtiles[focus_subtile]
			position = Hex.vertex_coords(focus_tile, focus_vertex)

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Hex.tile2world(focus_tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func event_processed():
	get_tree().get_root().set_input_as_handled()

func _input(event):
	if event is InputEventKey:
		if event.is_pressed(): return
		match event.keycode:
			KEY_ENTER:
				enter_subtile()
			KEY_ESCAPE:
				exit_subtile()
			KEY_UP:
				match cursor_mode:
					CursorMode.Tile: move_focus_tile(HexSide.Top)
					CursorMode.SubTile: move_focus_intile(true)
			KEY_DOWN:
				match cursor_mode:
					CursorMode.Tile: move_focus_tile(HexSide.Bottom)
					CursorMode.SubTile: move_focus_intile(false)
			KEY_RIGHT:
				match cursor_mode:
					CursorMode.Tile: move_focus_tile(HexSide.TopRight)
					CursorMode.SubTile: move_focus_intile(true)
			KEY_LEFT:
				match cursor_mode:
					CursorMode.Tile: move_focus_tile(HexSide.BottomLeft)
					CursorMode.SubTile: move_focus_intile(false)
			KEY_HOME:
				match cursor_mode:
					CursorMode.Tile: move_focus_tile(HexSide.TopLeft)
					CursorMode.SubTile: move_focus_intile(true)
			KEY_END:
				match cursor_mode:
					CursorMode.Tile: move_focus_tile(HexSide.BottomLeft)
					CursorMode.SubTile: move_focus_intile(false)
			KEY_PAGEDOWN:
				match cursor_mode:
					CursorMode.Tile: move_focus_tile(HexSide.BottomRight)
					CursorMode.SubTile: move_focus_intile(false)
			KEY_PAGEUP:
				match cursor_mode:
					CursorMode.Tile: move_focus_tile(HexSide.TopRight)
					CursorMode.SubTile: move_focus_intile(true)
			_: return
		event_processed()
