extends Entity

func _ready():
	add_to_group("items")
	create_outline_mesh()
	
func pick_up():
	get_parent().remove_child(self)
	self.translation = Vector3(0, 0, 0) #Resets the pos
	return self