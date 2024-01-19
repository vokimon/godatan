extends Object
class_name Hex

const tile_side = 100
const tile_width = tile_side * 2
const tile_heigth = tile_side * sqrt(3) # 173.20
const tile_margin = 0

enum Side {
	Top = 0,
	TopRight = +60,
	BottomRight = +120,
	Bottom = 180,
	BottomLeft = -120,
	TopLeft = -60,
}

enum Corner {
	TopRight = +30,
	Right = +90,
	BottomRight = +150,
	BottomLeft = -150,
	Left = -90,
	TopLeft = -30,
}

static func tile2world(tile_pos: Vector2i) -> Vector2:
	return Vector2(
		tile_pos.x * (tile_width * 0.75 + tile_margin),
		tile_pos.y * (tile_heigth + tile_margin) - tile_pos.x * (tile_heigth / 2. + tile_margin / 2.),
	)

static func tile_at_side(from: Vector2i, side: Side) -> Vector2i:
	match side:
		Side.Top:
			return Vector2i(from.x, from.y-1)
		Side.TopRight:
			return Vector2i(from.x+1, from.y)
		Side.BottomRight:
			return Vector2i(from.x+1, from.y+1)
		Side.Bottom:
			return Vector2i(from.x, from.y+1)
		Side.BottomLeft:
			return Vector2i(from.x-1, from.y)
		Side.TopLeft:
			return Vector2i(from.x-1, from.y-1)
	return from # Should not return

static func side_coords(from: Vector2i, side: Side) -> Vector2:
	return tile2world(from) + tile_heigth/2. * Vector2(
		sin(deg_to_rad(side)),
		-cos(deg_to_rad(side)),
	)

static func corner_coords(from: Vector2i, corner: Corner) -> Vector2:
	return tile2world(from) + tile_side * Vector2(
		sin(deg_to_rad(corner)),
		-cos(deg_to_rad(corner)),
	)

static func corner_peers(tile: Vector2i, corner: Corner) -> Array[Vector2i]:
	var solution = func(a,b): return [ tile_at_side(tile, a), tile_at_side(tile, b) ]
	match corner:
		Corner.TopRight:
			return solution.call(Side.Top, Side.TopRight)
		Corner.Right:
			return solution.call(Side.BottomRight, Side.TopRight)
		Corner.BottomRight:
			return solution.call(Side.BottomRight, Side.Bottom)
		Corner.BottomLeft:
			return solution.call(Side.BottomLeft, Side.Bottom)
		Corner.Left:
			return solution.call(Side.BottomLeft, Side.TopLeft)
		Corner.TopLeft:
			return solution.call(Side.Top, Side.TopLeft)
		_: return []

static func same_side(tile1: Vector2i, side1: Side, tile2: Vector2i, side2: Side):
	return (
		tile_at_side(tile1, side1) == tile2 and
		tile_at_side(tile2, side2) == tile1
	)

static func same_corner(tile1: Vector2i, corner1: Corner, tile2: Vector2i, corner2: Corner):
	return (
		tile1 in corner_peers(tile2, corner2) and
		tile2 in corner_peers(tile1, corner1) 
	)
