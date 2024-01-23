class_name HarbourOverlay
extends Node2D

@export var resource := Globals.ResourceType.Nothing:
	set(_resource):
		resource = _resource
		update_resource()
@export var side := Hex.Side.Top:
	set(_side):
		side = _side
		update_side()

func update_side():
	rotation = deg_to_rad(side)

func update_resource():
	if has_node("ExchangeRateLabel"):
		$ExchangeRateLabel.text = "3:1" if resource == Globals.ResourceType.Nothing else "2:1"
	if has_node("Speciality"):
		var resource_texture = Globals.resource_texture(resource)
		$Speciality.texture = resource_texture

func _init(_side := Hex.Side.Top, _resource := Globals.ResourceType.Nothing):
	self.resource = _resource
	self.side = _side

func _ready():
	update_resource()
	update_side()
