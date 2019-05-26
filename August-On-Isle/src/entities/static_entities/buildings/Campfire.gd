extends Building

onready var fire_container

func _ready():
	fire_container = $FirePosition
	var thread_util = ThreadUtil.new()
	thread_util.load_on_seperate_thread("res://src/entities/static_entities/misc/Fire.tscn")
	thread_util.connect("done_loading", self, "on_thread_loading_done")

func use():
	if fire_container.get_child_count() > 0: # done loading in background, fire exists!
		fire_container.get_node("Fire").toggle_emit_state()
		
func on_thread_loading_done(resource):
	fire_container.add_child(resource.instance())
	
		