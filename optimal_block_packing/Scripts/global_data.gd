class_name global_data extends Node

@export var container_width : float = 1
@export var container_depth : float = 1
@export var min_block_width : float = 0.1
@export var min_block_depth : float = 0.1

@export var blocks : Array = []
@export var candidate_points: Array = []

@export var animations_bool = true
@export var package_height = 0

func _ready() -> void:
	add_candidate_point(0,0,0)
	
func add_candidate_point(x: float, y: float, z: float) -> void:
	var point = Vector3(x, y, z)
	var idx = candidate_points.bsearch_custom(point, func(a, b):
		return sign(a.y - b.y)
	)
	candidate_points.insert(idx, point)
