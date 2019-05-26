extends Spatial

onready var flames = $Flames
onready var smoke = $Smoke
onready var omni_light = $OmniLight
onready var audio_player = $AudioStreamPlayer3D

var timer = null

func _ready():
	randomize()
	timer = Timer.new()
	timer.wait_time = 0.4
	timer.connect("timeout", self, "on_timer_timeout")
	add_child(timer)
	timer.start()

func toggle_emit_state():
	flames.emitting = !flames.emitting
	smoke.emitting = !smoke.emitting
	omni_light.visible = !omni_light.visible
	if flames.emitting:
		audio_player.playing = true
	else:
		audio_player.playing = false
	
	
func on_timer_timeout():
	omni_light.light_energy = rand_range(0.7, 1.0)
	timer.wait_time = rand_range(0.05, 0.1)
	
	
