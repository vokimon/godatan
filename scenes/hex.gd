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
