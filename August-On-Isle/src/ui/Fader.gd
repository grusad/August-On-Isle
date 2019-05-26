extends ColorRect

onready var anim_player = $AnimationPlayer

export (float) var playback_speed = 1

signal fade_finished

const NO_FLAG = -1
var fade_flag = NO_FLAG


func _ready():
	anim_player.playback_speed = playback_speed
	visible = false

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("fade_finished", fade_flag)
	
func fade_in(fade_flag = NO_FLAG):
	self.fade_flag = fade_flag
	visible = true
	anim_player.play("fade_in")

func fade_out(fade_flag = NO_FLAG):
	self.fade_flag = fade_flag
	visible = true
	anim_player.play("fade_out")
