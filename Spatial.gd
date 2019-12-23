tool
extends Spatial

# Declare member variables here. Examples:
var noiseOffset = 0

var open_simplex_noise
export (float, 0, 100) var height = 60
export (float, -1, 1) var deepWaterTreshold = -0.8
export (float, -1, 1) var waterTreshold = -0.6

export (float, 0, 5) var deepWaterSlope = 0.1
export (float, 0, 5) var waterSlope = 1
export (float, 0, 5) var landSlope = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	open_simplex_noise = OpenSimplexNoise.new()
	open_simplex_noise.seed = randi()
	
	open_simplex_noise.octaves = 6
	open_simplex_noise.period = 80
	open_simplex_noise.persistence = 0.4
	
	_generateWorld()

func _heightTransformer(height):
	height-=waterTreshold
	if height < -(waterTreshold-deepWaterTreshold): 
		return height * deepWaterSlope + (deepWaterTreshold - waterTreshold) * (waterSlope - deepWaterSlope)
	if height < 0:
		return height * waterSlope;
	else :
		#is on land
		return height * landSlope
func _generateWorld():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(128, 128)
	
	plane_mesh.subdivide_depth = 500
	plane_mesh.subdivide_width = 500
	
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
	
	var mesh_instance = MeshInstance.new();
	mesh_instance.mesh = surface_tool.commit();
	
	mesh_instance.set_surface_material(0, load("res://sand.material"));
	mesh_instance.create_trimesh_collision()
	
	add_child(mesh_instance);

