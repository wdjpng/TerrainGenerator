extends MeshInstance

# Declare member variables here. Examples:
var height = 500
var width = 500
var noiseOffset = 0

var open_simplex_noise

const TILES = {
	'grass_higher': 1,
	'grass_lower': 0,
	'rock': 3,
	'water': 2
}
	
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	open_simplex_noise = OpenSimplexNoise.new()
	open_simplex_noise.seed = randi()
	
	open_simplex_noise.octaves = 5
	open_simplex_noise.period = 80
	
	_generateWorld()

func _generateWorld():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(800, 800)
	
	plane_mesh.subdivide_depth = 400
	plane_mesh.subdivide_width = 400
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_plane = surface_tool.commit()
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = open_simplex_noise.get_noise_3d(vertex.x, noiseOffset, vertex.z) * 60
		
		data_tool.set_vertex(i, vertex)
	
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)
	
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	mesh = surface_tool.commit()
	create_trimesh_collision()

func _get_tile_index(height):
	if height < -0:
		return TILES.water
	if height < 0.3 :
		return TILES.grass_lower
	if height < 0.5 :
		return TILES.grass_higher
	return TILES.rock
