extends Node2D

@export var id: int = 0
@export var width: float = 1.0
@export var depth: float = 1.0
@export var height: float = 1.0

@onready var polygon = $polygon
@onready var label = $Block_id_label

func setup_block_preview(_id : int , _width: float, _depth: float, _height: float) -> void:
	id = _id
	width = _width
	depth = _depth
	height = _height
	label.text = str("Id: " + str(id))
	draw()

func draw():
	var multiplier  = max(GlobalData.max_block_width,GlobalData.max_block_depth,GlobalData.max_block_height)
	var w = 50 * width / multiplier
	var d = 50 * depth / multiplier
	var h = 50 * height / multiplier

	var offset = Vector2(80/2, 120/2)  # centar Node2D

	# Gornje lice - prvo
	var top = Polygon2D.new()
	top.polygon = [
		Vector2(0,0),
		Vector2(w,0),
		Vector2(w+d/2,-d/2),
		Vector2(d/2,-d/2)
	]
	top.color = Color(0.8,0.8,0.8)
	top.position = offset - Vector2(w/2, h/2)
	polygon.add_child(top)

	# Bočno lice - drugo
	var side = Polygon2D.new()
	side.polygon = [
		Vector2(0,0),
		Vector2(d/2,-d/2),
		Vector2(d/2,-h-d/2),
		Vector2(0,-h)
	]
	side.color = Color(0.5,0.5,0.5)
	side.position = offset + Vector2(w/2, h/2)
	polygon.add_child(side)

	# Prednje lice - poslednje
	var front = Polygon2D.new()
	front.polygon = [
		Vector2(0,0),
		Vector2(w,0),
		Vector2(w,-h),
		Vector2(0,-h)
	]
	front.color = Color(0.6,0.6,0.6)
	front.position = offset - Vector2(w/2, -h/2)
	polygon.add_child(front)
	polygon.position.y = 10
	polygon.position.x -= 10
