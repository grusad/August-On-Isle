extends Node
class_name ThreadUtil

signal done_loading

#Method to load a scene on a seperat thread and when done loading emit a signal and return resource. This prevents the game from freezing if the
#loading of scene is a heavy operation.
func load_on_seperate_thread(path):
	var thread = Thread.new()
	var data = Data.new(ResourceLoader.load_interactive(path), thread)
	thread.start(self, "prepare_scene", data)
	
func prepare_scene(data):
	
	var loader = data.loader
	
	while true:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			
			call_deferred("on_load_done", data)
			return loader.get_resource()

func on_load_done(data):
	
	var resource = data.thread.wait_to_finish()
	emit_signal("done_loading", resource)

#Class used for loading scenes and nodes on seperat thread. Used by method "load_on_seperate_thread"-method.
class Data:

	var loader = null
	var thread = null
	
	func _init(loader, thread):
		self.loader = loader
		self.thread = thread
	