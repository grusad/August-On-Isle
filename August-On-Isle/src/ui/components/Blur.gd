extends ColorRect

onready var anim_player = $AnimationPlayer

export (float) var playback_speed = 1

signal blur_finished

const NO_FLAG = -1
var blur_flag = NO_FLAG


func _ready():
	anim_player.playback_speed = playback_speed

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("blur_finished", blur_flag)
	
func blur_in(fade_flag = NO_FLAG):
	self.blur_flag = blur_flag
	anim_player.play("blur_in")

func blur_out(fade_flag = NO_FLAG):
	self.blur_flag = blur_flag
	anim_player.play("blur_out")
