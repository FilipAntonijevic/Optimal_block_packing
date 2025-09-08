extends Resource 
class_name CandidatePoint

@export var x: float
@export var y: float
@export var z: float

func _init(_x: float = 0, _y: float = 0, _z: float = 0) -> void:
	x = _x
	y = _y
	z = _z
	
func debug_str() -> String:
	return "Point(x=%.3f, y=%.3f, z=%.3f)" % [x, y, z]
