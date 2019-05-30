extends Entity
class_name Element

enum Type {Tree, Rock, Grass}
export (Type) var type

export (int) var hp = 100

func _ready():
	add_to_group("element")
	
	
func mine(dmg):
	hp -= dmg
	if hp < 0:
		remove()

	