extends Entity
class_name Item

enum Type {Axe, Pickaxe, Other}
export (Type) var type

export (int) var dmg = 5

func _ready():
	add_to_group("items")
	add_to_group("interactable")
	create_outline_mesh()
	
func pick_up():
	get_parent().remove_child(self)
	self.translation = Vector3(0, 0, 0) #Resets the pos
	return self
	
func get_hints():
	return ["[LMB] Pick up", "[RMB] Move"]
	