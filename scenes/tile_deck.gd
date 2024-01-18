class_name TileDeck
extends Resource
const Terrain = Globals.Terrain

"""
A deck is a set of terrain tiles that are placed on the board in assigned spaces in the board.
The deck may be shuffled or not and may be hidden on start or not.
A deck also may have number tokens to be asigned to the tiles.
"""
@export var name: String
@export var tiles: Array[Terrain] = [] ##< If not shuffled, fill in order top bottom, left to right
@export var numbers: Array[int] = []
@export var shuffled: bool = false ##< Tiles (and number tokens) should be shuffled before placement
@export var hidden: bool = false ##< Tiles are placed facing down on start
@export var unnumbered: Array[Terrain] = [] ##< Those type of tiles will not be numbered (ie, Desert, Sea...)

