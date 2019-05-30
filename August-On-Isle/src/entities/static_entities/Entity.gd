extends StaticBody
class_name Entity

var outline_mesh_instance = null
var outline_material = preload("res://materials/outline_material.material")


func _ready():
	add_to_group("save")
	
func create_outline_mesh():
	var mesh_instance = get_child(0)
	var outline = mesh_instance.mesh.create_outline(0.03)
	outline_mesh_instance = MeshInstance.new()
	outline_mesh_instance.mesh = outline
	outline_mesh_instance.visible = false
	outline_mesh_instance.set_surface_material(0, outline_material)
	mesh_instance.add_child(outline_mesh_instance)

func remove():
	queue_free()
	
func save_json():
	var save_data = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"translation" : Utils.vec3_to_dict(translation),
		"rotation" : Utils.vec3_to_dict(rotation_degrees),
		"scale" : Utils.vec3_to_dict(scale)
	
	}
	return save_data

func set_targeting(targeting):
	
	if outline_mesh_instance == null:
		return
	
	if targeting:
		outline_mesh_instance.visible = true
	else:
		outline_mesh_instance.visible = false
	

func load_json(data_dict):
	translation = Utils.dict_to_vec3(data_dict["translation"])
	rotation_degrees = Utils.dict_to_vec3(data_dict["rotation"])
	scale = Utils.dict_to_vec3(data_dict["scale"])
	
func get_hold_hints():
	
	return ["[RMB] Place", "[SCROLL] Rotate"]
	
	