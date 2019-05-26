extends Node

var save_folder = "res://debug/save"
var save_name_template = "save_%03d.json"
		
func save_json(id):
	var save_file = File.new()
	var directory = Directory.new()
	if not directory.dir_exists(save_folder):
		directory.make_dir_recursive(save_folder)

	var save_path = save_folder.plus_file(save_name_template % id)
	save_file.open(save_path, File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("save")
	
	for node in save_nodes:
		var node_data = node.save_json()
		save_file.store_line(to_json(node_data))
	
	save_file.close()

func load_json(id):
	var save_file = File.new()
	var save_path = save_folder.plus_file(save_name_template % id)
	if not save_file.file_exists(save_path):
		return
	
	save_file.open(save_path, File.READ)
	
	# removes all the nodes that will be recreated in the game to avoid duplicated objects.
	var save_nodes = get_tree().get_nodes_in_group("save")
	for node in save_nodes:
		if node.save_json().has("filename"):
			node.queue_free()
	
	while not save_file.eof_reached():
		var current_line = parse_json(save_file.get_line())
		if current_line == null:
			continue
		
		#if scene has stored the filename, the scene will be recreated.
		if current_line.has("filename"):	
			var new_object = load(current_line["filename"]).instance()
			get_node(current_line["parent"]).add_child(new_object)
			new_object.load_json(current_line)
			
		#if scene has stored the path, it will not be recreated			
		elif current_line.has("path"):
			get_node(current_line["path"]).load_json(current_line)
			
			
	
	save_file.close()
		
func save_file_exists(id):
	var save_file = File.new()
	var save_path = save_folder.plus_file(save_name_template % id)
	return save_file.file_exists(save_path)
		
		
		
		
		
	