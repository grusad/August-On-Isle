extends Node

onready var menu = $Menu
onready var world = preload("res://src/world/World.tscn")
var world_instance = null


func _ready():
	set_process(false)
	
func new_game():
	hide_menu()
	
	world_instance = world.instance()
	add_child(world_instance)
	world_instance.new_world(1)
	
func load_game():
	
	hide_menu()
	world_instance = world.instance()
	add_child(world_instance)
	world_instance.load_world(1) 
	
func hide_menu():
	menu.visible = false
		
		
		
		
		
		