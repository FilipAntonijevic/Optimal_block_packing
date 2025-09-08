extends Resource 
class_name OverlapControlPoint

@export var x: float
@export var y: float
@export var z: float
@export var width: float
@export var depth: float

func _init(_x: float = 0, _y: float = 0, _z: float = 0, _width: float = 0, _depth: float = 0) -> void:
	x = _x
	y = _y
	z = _z
	width = _width
	depth = _depth
func overlaps(best_point: CandidatePoint, block_width: float, block_depth: float) -> bool:
	var ax1 = best_point.x
	var ax2 = best_point.x + block_width
	var az1 = best_point.z
	var az2 = best_point.z + block_depth

	var bx1 = x
	var bx2 = x + width
	var bz1 = z
	var bz2 = z + depth
	return not (ax2 <= bx1 or bx2 <= ax1 or az2 <= bz1 or bz2 <= az1)

func debug_str() -> String:
	return "Point(x=%.3f, y=%.3f, z=%.3f, width=%.3f, depth=%.3f)" % [x, y, z, width, depth]
