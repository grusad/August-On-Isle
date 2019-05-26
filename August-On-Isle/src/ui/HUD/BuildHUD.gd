extends Control

signal spawn_build

onready var build_buttons = $TabContainer/Build/Buttons
onready var craft_buttons = $TabContainer/Craft/Buttons
onready var button_scene = load("res://src/ui/components/CustomButton.tscn")


func _ready():
	populate("res://src/entities/static_entities/buildings", build_buttons)
	populate("res://src/entities/static_entities/items", craft_buttons)


func populate(path, container):
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var button = button_scene.instance()
			button.text = file_name.substr(0, file_name.length() - 5)
			button.connect("pressed", self, "on_button_pressed", [path + "/" + file_name])
			container.add_child(button)
			
		file_name = dir.get_next()

func on_button_pressed(path):
	emit_signal("spawn_build", path)
	