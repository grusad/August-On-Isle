extends Spatial

onready var terrain = $Terrain
onready var object_container = $ObjectsContainer
onready var player = $Player
onready var fader = $Fader
onready var music_plaer = $MusicPlayer

func _ready():
	player.connect("place_object", self, "on_player_placed_object")
	
	
func new_world(world_id):
	terrain.generate_new()
	player.translation = terrain.get_random_avalible_vertex() + Vector3(0, 1, 0)
	GameSaver.save_json(world_id)
	fader.fade_in()


func load_world(world_id):
	GameSaver.load_json(world_id)
	yield(get_tree(), "idle_frame")
	fader.fade_in()

	
func on_player_placed_object(object, object_transform):
	object.global_transform = object_transform
	object_container.add_child(object)