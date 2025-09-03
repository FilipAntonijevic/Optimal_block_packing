extends Node3D

@export var height: float = 12.0
@export var color: Color = Color(1, 1, 1)

func _ready() -> void:
	draw_container(2, 2)


func draw_container(width: float, depth: float) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)

	var hw = width / 2.0
	var hh = height / 2.0
	var hd = depth / 2.0

	var corners = [
		Vector3(-hw, 0, -hd),
		Vector3(hw, 0, -hd),
		Vector3(hw, height, -hd),
		Vector3(-hw, height, -hd),
		Vector3(-hw, 0, hd),
		Vector3(hw, 0, hd),
		Vector3(hw, height, hd),
		Vector3(-hw, height, hd)
	]


	var edges = [
		[0,1],[1,2],[2,3],[3,0], # zadnja strana
		[4,5],[5,6],[6,7],[7,4], # prednja strana
		[0,4],[1,5],[2,6],[3,7]  # spajanje
	]

	for e in edges:
		st.set_color(color)
		st.add_vertex(corners[e[0]])
		st.set_color(color)
		st.add_vertex(corners[e[1]])

	var mesh = st.commit()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)

	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mesh_instance.material_override = mat
