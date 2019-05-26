extends Node

func create_plane_mesh(size, subdiv_depth, subdiv_width):
	var plane_mesh = PlaneMesh.new()
	plane_mesh.subdivide_depth = subdiv_depth
	plane_mesh.subdivide_width = subdiv_width
	plane_mesh.size = Vector2(size, size)
	return plane_mesh
	
func vec3_to_dict(vec3):
	var data = {
		"x" : vec3.x,
		"y" : vec3.y,
		"z" : vec3.z
	}
	return data

func dict_to_vec3(dict):
	var vec3 = Vector3()
	vec3.x = dict["x"]
	vec3.y = dict["y"]
	vec3.z = dict["z"]
	return vec3


