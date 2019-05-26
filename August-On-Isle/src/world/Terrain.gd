extends Spatial

const NO_SEED = -1
const SIZE = 250

const TREES_AMOUNT = 100
const GRASS_AMOUNT = 220
const ROCKS_AMOUNT = 36

const SUBFOLDER_TREES = "trees"
const SUBFOLDER_GRASS = "grass"
const SUBFOLDER_ROCKS = "rocks"
const SUBFOLDER_RESOURCE = "resources"

onready var element_container = get_parent().get_node("ElementContainer")
	
var data_tool : MeshDataTool
var noise : OpenSimplexNoise

var loaded_elements = {
	SUBFOLDER_TREES : [],
	SUBFOLDER_GRASS : [],
	SUBFOLDER_ROCKS : []
}

var loaded_resources = []

var avalible_verticies = []

func _ready():
	randomize()
	load_elements_from_subfolder(SUBFOLDER_TREES)
	load_elements_from_subfolder(SUBFOLDER_GRASS)
	load_elements_from_subfolder(SUBFOLDER_ROCKS)
	
	
	noise = OpenSimplexNoise.new()
	

# Reads element names from subfolder within the elementsfolder. the subfolder must match the key in the element_names dictionary
func load_elements_from_subfolder(subfolder):
	var dir = Directory.new()
	var path = "res://src/entities/static_entities/elements/" + subfolder
	dir.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name != ""):
		
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			loaded_elements[subfolder].push_back(load(path + "/" + file_name))
			
		file_name = dir.get_next()

func generate_terrain(seed_data = NO_SEED):
	
	if seed_data != NO_SEED:
		noise.seed = seed_data
	else:
		noise.seed = randi()

	noise.octaves = 5
	noise.period = 80
	var surface_tool = SurfaceTool.new()
	data_tool = MeshDataTool.new()
	var plane_mesh = Utils.create_plane_mesh(SIZE, SIZE * 0.5, SIZE * 0.5)
	var material = load("res://materials/terrain_material_shader.material")
	plane_mesh.material = material
	
	surface_tool.create_from(plane_mesh, 0)
	var array_plane = surface_tool.commit()
	var error = data_tool.create_from_surface(array_plane, 0)

	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		var xp = vertex.x
		var zp = vertex.z
		
		var distance_x = abs(xp)
		var distance_z = abs(zp)
		var distance = sqrt(distance_x * distance_x + distance_z * distance_z)
		
		var max_width = SIZE * 0.5
		var delta = distance / max_width
		var gradient = delta * delta * delta * delta
		var value = noise.get_noise_3d(vertex.x, vertex.y, vertex.z) 
		value -= gradient 
		vertex.y = value * 40
		
		data_tool.set_vertex(i, vertex)
		
		#if vertex is above sealevel
		if vertex.y > 0:
			avalible_verticies.push_back(vertex)
		
	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)
		
	
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()

	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	
	mesh_instance.create_trimesh_collision()
	#is this needed...?
	mesh_instance.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
	
	add_child(mesh_instance)
	
	generate_water()
	
func generate_water():

	var plane_mesh = Utils.create_plane_mesh(SIZE * 4, SIZE, SIZE)
		
	var material = load("res://materials/water_material.material")
	
	plane_mesh.material = material
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = plane_mesh
	mesh_instance.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
	
	add_child(mesh_instance)

func get_random_vertex():
	return data_tool.get_vertex(rand_range(0, data_tool.get_vertex_count() - 1.0))
		
func get_random_avalible_vertex():
	
	if not avalible_verticies.empty():
		var index = int(rand_range(0, avalible_verticies.size() - 1.0))
		var vertex = avalible_verticies[index]
		avalible_verticies.remove(index)
		return vertex

	return null
	
	

func add_entity(instance, vertex, min_scale, max_scale, parent):
	instance.translation.x = vertex.x
	instance.translation.y = vertex.y
	instance.translation.z = vertex.z
	var scale = rand_range(min_scale, max_scale)
	instance.scale = Vector3(scale, scale, scale)
	instance.rotation_degrees = Vector3(rand_range(-5, 5), rand_range(0.0, 360.0), rand_range(-5.0, 5.0))
		
	#get_parent().get_node("ElementContainer").add_child(instance)
	parent.add_child(instance)


func generate_elements(subfolder, amount, max_scale):
	for i in amount:
		var vertex = get_random_avalible_vertex()
		if vertex == null: # Theres no avalible verticies...
			return
		add_entity(get_random_element(subfolder), vertex, 1, max_scale, element_container)
			


func generate_new():
	generate_terrain()
	
	generate_elements(SUBFOLDER_TREES, TREES_AMOUNT, 4)
	generate_elements(SUBFOLDER_GRASS, GRASS_AMOUNT, 2)
	generate_elements(SUBFOLDER_ROCKS, ROCKS_AMOUNT, 10)
	
	
		

func get_random_element(subfolder):
	var random_tree = loaded_elements[subfolder][rand_range(0, loaded_elements[subfolder].size())]
	return random_tree.instance()

func save_json():
	var save_data = {
		"path" : get_path(),
		"seed" : noise.seed,
		"translation" : Utils.vec3_to_dict(translation)
	}
	return save_data

func load_json(data_dict):
	
	translation = Utils.dict_to_vec3(data_dict["translation"])
	generate_terrain(data_dict["seed"])

		
		
	
	
