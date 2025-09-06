extends Resource 
class_name CandidatePoint

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

func overlaps(other: CandidatePoint, block_width: float, block_depth: float) -> bool:
	var ax1 = x
	var ax2 = x + block_width
	var az1 = z
	var az2 = z + block_depth

	var bx1 = other.x
	var bx2 = other.x + other.width
	var bz1 = other.z
	var bz2 = other.z + other.depth

	if bx1 > bx2:
		var tmp = bx1
		bx1 = bx2
		bx2 = tmp
	if bz1 > bz2:
		var tmp = bz1
		bz1 = bz2
		bz2 = tmp

	return not (ax2 <= bx1 or bx2 <= ax1 or az2 <= bz1 or bz2 <= az1)


func debug_str() -> String:
	return "Point(x=%.3f, y=%.3f, z=%.3f, width=%.3f, depth=%.3f)" % [x, y, z, width, depth]
