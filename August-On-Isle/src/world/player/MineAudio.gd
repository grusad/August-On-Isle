extends Node

func play():
	var count = get_child_count()
	for i in range(count):
		var stream = get_child(i)
		if not stream.playing:
			stream.pitch_scale = rand_range(0.8, 1.0)
			stream.play()
			break