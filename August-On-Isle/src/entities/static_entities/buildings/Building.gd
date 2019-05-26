extends Entity
class_name Building

func _ready():
	add_to_group("building")
	self.create_outline_mesh()

#SHould be overridden by derived scenes!
func use():
	print("Using object: [",name, "]")