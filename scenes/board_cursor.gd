extends Marker2D

const HexSide = Board.HexSide
const HexVertex = Board.HexVertex

enum FocusLevel {Tile, Side, Vertex}

@export_category("Board Cursor")
@export var focus_level: FocusLevel = FocusLevel.Tile
@export var focus_tile: Vector2i = Vector2i.ZERO
@export var focus_side: HexSide = HexSide.Top
@export var focus_vertex: HexVertex = HexVertex.TopRight

func focus_cycle(forward: bool = true):
	var levels: Array = FocusLevel.values()
	var previous: int = levels.find(focus_level)
	focus_level = levels[clamp(previous+(+1 if forward else -1), 0, len(levels)-1)]
	if previous != focus_level:
		focus_side = HexSide.Top
		focus_vertex = HexVertex.TopRight
	update_focus()

func move_focus_tile(side: HexSide):
	var new_pos = get_parent().tile_at_side(focus_tile, side)
	if new_pos not in get_parent().board_tiles:
		return
	focus_tile = new_pos
	update_focus()

func move_focus_side(forward: bool):
	var sides: Array = HexSide.values()
	var previous: int = sides.find(focus_side)
	var movement = 1 if forward else -1
	focus_side = sides[(previous+movement)%len(sides)]
	update_focus()

func move_focus_vertex(forward: bool):
	var vertexes: Array = HexVertex.values()
	var previous: int = vertexes.find(focus_vertex)
	var movement = 1 if forward else -1
	focus_vertex = vertexes[(previous+movement)%len(vertexes)]
	update_focus()

func update_focus():
	match focus_level:
		FocusLevel.Tile:
			position = get_parent().tile2world(focus_tile)
		FocusLevel.Side:
			position = get_parent().side_coords(focus_tile, focus_side)
		FocusLevel.Vertex:
			position = get_parent().vertex_coords(focus_tile, focus_vertex)


# Called when the node enters the scene tree for the first time.
func _ready():
	position = get_parent().tile2world(focus_tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _input(event):
	if event is InputEventKey:
		if event.is_pressed(): return
		match event.keycode:
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
