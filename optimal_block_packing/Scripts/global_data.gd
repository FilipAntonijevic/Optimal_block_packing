class_name global_data
extends Node

@export var container_width: float = 1
@export var container_depth: float = 1
@export var min_block_width: float = 0.1
@export var min_block_depth: float = 0.1
@export var max_block_height: float = 5

@export var blocks: Array = []
@export var candidate_points: Array[CandidatePoint] = []  # koristi Resource klasu

@export var animations_bool: bool = true
@export var package_height: float = 0

func _ready() -> void:
	add_candidate_point(0, 0, 0, 0, 0)

func add_candidate_point(x: float, y: float, z: float, width: float, depth: float) -> void:
	var point = CandidatePoint.new()
	point.x = x
	point.y = y
	point.z = z
	point.width = width
	point.depth = depth
	
	var idx = candidate_points.bsearch_custom(point, func(a, b):
		if a.y != b.y:
			return a.y < b.y  
		else:
			return (a.x + 1) * (a.z + 1) < (b.x + 1) * (b.z + 1) 
	)

	candidate_points.insert(idx, point)

func get_height() -> float:
	return candidate_points.back().y
