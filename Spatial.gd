tool
extends Spatial

const chunk_size = 128
var chunk_amount =  10

var noise
var chunks = {}
var unready_chunks = {}
var thread

func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	
	noise.octaves = 6
	noise.period = 80
	noise.persistence = 0.4
	
	thread = Thread.new()
	
	if Engine.is_editor_hint():
		chunk_amount = 0
		add_chunk(0, 0)
	
func add_chunk(x, z):
	var key = str(x) + "," + str(z)
	
	if chunks.has(key) or unready_chunks.has(key):
		return
		
	if not thread.is_active():
		thread.start(self, "load_chunk", [thread, x, z])
		unready_chunks[key] = 1
		
func load_chunk(arr):
	var thread = arr[0]
	var x = arr[1]
	var z = arr[2]
	
	var chunk = Chunk.new(noise, x * chunk_size, z * chunk_size, chunk_size)
	chunk.translation = Vector3(x * chunk_size, 0, z*chunk_size)
	
	call_deferred("load_done", chunk, thread)
	
func load_done(chunk, thread):
	add_child(chunk)
	var key = str(chunk.x / chunk_size) + "," + str(chunk.z / chunk_size)
	chunks[key] = chunk
	unready_chunks.erase(key)
	thread.wait_to_finish()

func get_chunk(x, z):
	var key = str(x) + "," + str(z)
	if chunks.has(key):
		return chunks.get(key)
	
	return null

func _process(delta):
	if Engine.is_editor_hint():
		return
		
	update_chunks()
	clean_up_chunks()
	reset_chunks()

func update_chunks():
	var player_translation = $Player.translation
	
	var p_x = int(player_translation.x) / chunk_size
	var p_z = int(player_translation.z) / chunk_size
	
	for distanceFromPlayer in range(0, chunk_amount):
		for x in range(0, chunk_amount):
			for z in range(0, chunk_amount):
				var currentDistancefromPlayer = sqrt(pow(x, 2) + pow(z, 2))
				print(currentDistancefromPlayer)
				if currentDistancefromPlayer > distanceFromPlayer and distanceFromPlayer < chunk_amount + 1:
					add_chunk(-x, -z)
					var chunk0 = get_chunk(-x, -z)
					if chunk0 != null:
						chunk0.should_remove = false
						
					add_chunk(x, -z)
					var chunk1 = get_chunk(-x, z)
					if chunk1 != null:
						chunk1.should_remove = false
					
					add_chunk(-x, z)
					var chunk2 = get_chunk(x, -z)
					if chunk2 != null:
						chunk2.should_remove = false
						
					add_chunk(x, z)
					var chunk3 = get_chunk(x, z)
					if chunk3 != null:
						chunk3.should_remove = false
				
func clean_up_chunks():
	for key in chunks:
		var chunk = chunks[key]
		if chunk.should_remove:
			chunk.queue_free()
			chunks.erase(key)

func reset_chunks():
	for key in chunks:
		chunks[key].should_remove = true
