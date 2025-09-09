class_name global_data
extends Node

@export var container_width: float = 1
@export var container_depth: float = 1
@export var min_block_width: float = 0.1
@export var min_block_depth: float = 0.1
@export var max_block_height: float = 3.0
@export var max_block_width: float  = 1
@export var max_block_depth: float  = 1


@export var blocks: Array = []
@export var candidate_points: Array[CandidatePoint] = [] 
@export var overlap_control_points: Array[OverlapControlPoint] = []
@export var lowest_candidate_point_height : float = 0

@export var render_visual_storage : bool = true
@export var animations_bool: bool = true
@export var view_2d : bool = false
@export var calculation_in_progress : bool = false

@export var package_height: float = 0

func _ready() -> void:
	add_candidate_point(0, 0, 0)

func add_overlap_control_point_point(x: float, y: float, z: float, width: float, depth: float) -> void:
	var point = OverlapControlPoint.new()
	point.x = x
	point.y = y
	point.z = z
	point.width = width
	point.depth = depth
	overlap_control_points.append(point)
	
func add_candidate_point(x: float, y: float, z: float) -> void:
	var point = CandidatePoint.new()
	point.x = x
	point.y = y
	point.z = z
	candidate_points.append(point)

func get_height() -> float:
	var height = 0
	for t in candidate_points:
		if t.y > height:
			height = t.y
	return height
