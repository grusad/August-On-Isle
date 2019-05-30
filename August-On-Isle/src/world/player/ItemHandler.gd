extends Node

func handle_item(wielding_item, ray_collider):
	match wielding_item.type:
		Item.Type.Axe:
			if ray_collider.type == Element.Type.Tree:
				ray_collider.mine(wielding_item.dmg)
				
		Item.Type.Pickaxe:
			if ray_collider.type == Element.Type.Rock:
				ray_collider.mine(wielding_item.dmg)
				
			
			
			