class_name TileCorner
extends Resource

@export var tile: Vector2i
@export var corner: Hex.Corner

func is_peer(other: TileCorner):
	return Hex.same_corner(tile, corner as Corner, other.tile, other.corner as Corner)

func neighbour(side: Hex.Side, corner: Hex.Corner) -> TileCorner:
	"""Returns the corner at corner of the neighbour at side"""
	# TODO: Learn gdscript to simplify this
	var tileCorner = TileCorner.new()
	tileCorner.tile = Hex.tile_at_side(tile, side as Side)
	tileCorner.corner = corner
	return tileCorner
	
func canonical() -> TileCorner:
	"""Only TileCorner with right and left corners are canonical"""
	match corner:
		Hex.Corner.TopLeft: return neighbour(Hex.Side.TopLeft, Hex.Corner.Right)
		Hex.Corner.Left: return self
		Hex.Corner.BottomLeft: return neighbour(Hex.Side.BottomLeft, Hex.Corner.Right)
		Hex.Corner.BottomRight: return neighbour(Hex.Side.BottomRight, Hex.Corner.Left)
		Hex.Corner.Right: return self
		Hex.Corner.TopRight: return neighbour(Hex.Side.TopRight, Hex.Corner.Left)
		_: return self # To make compiler happy

