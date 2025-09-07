extends Node2D

@export var id: int = 0
@export var width: float = 1.0
@export var depth: float = 1.0
@export var height: float = 1.0

func setup_block_preview(_id : int , _width: float, _depth: float, _height: float) -> void:
	id = _id
	width = _width
	depth = _depth
	height = _height
	$Block_id_label.text = str(id)
	update() 
	
func _draw():
	var w = width / GlobalData.min_block_width * 80
	var d = depth / GlobalData.max_block_depth * 60
	var h = height / GlobalData.max_block_height * 40

	var front = [
		Vector2(0, 0),
		Vector2(w, 0),
		Vector2(w, -h),
		Vector2(0, -h)
	]
	# Bočno lice
	var side = [
		Vector2(w, 0),
		Vector2(w + d/2, -d/2),
		Vector2(w + d/2, -h - d/2),
		Vector2(w, -h)
	]
	# Gornje lice
	var top = [
		Vector2(0, -h),
		Vector2(w, -h),
		Vector2(w + d/2, -h - d/2),
		Vector2(d/2, -h - d/2)
	]

	draw_polygon(front, [Color(0.6,0.6,0.6)])
	draw_polygon(side, [Color(0.4,0.4,0.4)])
	draw_polygon(top, [Color(0.8,0.8,0.8)])
