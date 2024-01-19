class_name TileDeck
extends Resource
const Terrain = Globals.Terrain
const ResourceType = Globals.ResourceType

"""
A deck is a group of terrain tiles that are placed on assigned spaces
in the board for that deck.
The deck may be shuffled or not and may be hidden on start or not.
A deck may also have number tokens to be asigned to the tiles.
A deck may also include port resource specializations to assign
(shuffled or not) to sea tiles with ports.
"""

@export var name: String
@export var tiles: Array[Terrain] = [] ##< If not shuffled, fill in order top bottom, left to right
@export var numbers: Array[int] = [] ##< Number tokens
@export var shuffled: bool = false ##< Tiles (and number tokens) should be shuffled before placement
@export var hidden: bool = false ##< Tiles are placed facing down on start
@export var unnumbered: Array[Terrain] = [] ##< Those type of tiles will not be numbered (ie, Desert, Sea...)
@export var port_resources: Array[ResourceType] = [] ##< Port resource specialization tiles
@export var ports_shuffled: bool = false ##< Port specialization should be shuffled or not
