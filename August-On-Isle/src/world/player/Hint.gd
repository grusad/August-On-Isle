extends PanelContainer

onready var container = $MarginContainer/VBoxContainer

onready var anim_player = $AnimationPlayer

func show_hints(hints):
	if visible:
		return
		
	for hint in hints:
		var label = Label.new()
		label.text = hint
		container.add_child(label)
	visible = true
	
	anim_player.play("fade_in")

func hide_hints():
	
	if not visible:
		return
	
	for index in range(container.get_child_count()):
		container.get_child(index).queue_free()
		
	visible = false
	
	anim_player.play("fade_out")