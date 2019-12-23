
extends MeshInstance

# Declare member variables here. Examples:
var height = 60
var noiseOffset = 0

var open_simplex_noise

	
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	open_simplex_noise = OpenSimplexNoise.new()
	open_simplex_noise.seed = randi()
	
	open_simplex_noise.octaves = 6
	open_simplex_noise.period = 80

	
	#_generateWorld()

func _heightTransformer(height):
	return height
func _generateWorld():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(512, 512)
	
	plane_mesh.subdivide_depth = 100
	plane_mesh.subdivide_width = 100
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_plane = surface_tool.commit()
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = _heightTransformer(open_simplex_noise.get_noise_3d(vertex.x, noiseOffset, vertex.z)) * height 
		data_tool.set_vertex(i, vertex)
	
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)
	
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	mesh = surface_tool.commit()
	set_surface_material(0, load("res://terrain.material"));
	create_trimesh_collision()


