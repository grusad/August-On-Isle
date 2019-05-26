extends WorldEnvironment

var base_night_sky_rotation = Basis(Vector3(1.0, 1.0, 1.0).normalized(), 1.2)
var horizontal_angle = 25.0

onready var sky_texture = $SkyTexture
onready var dir_light = $DirectionalLight
var time_of_day = 7

func _set_sky_rotation():
	var rot = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(horizontal_angle)) * Basis(Vector3(1.0, 0.0, 0.0), time_of_day * PI / 12.0)
	rot = rot * base_night_sky_rotation;
	sky_texture.set_rotate_night_sky(rot)

func _ready():
	
	# init our time of day
	sky_texture.set_time_of_day(time_of_day, dir_light, deg2rad(horizontal_angle))
	
	# rotate our night sky so our milkyway isn't on our horizon
	_set_sky_rotation()
	
	var sky_updater = Timer.new()
	sky_updater.wait_time = 4
	sky_updater.connect("timeout", self, "on_timer_timeout")
	sky_updater.start()
	add_child(sky_updater)
	
func on_timer_timeout():
	time_of_day += 0.02
	_on_Time_Of_Day_value_changed(time_of_day)
	

func _on_Time_Of_Day_value_changed(value):
	
	sky_texture.set_time_of_day(value, dir_light, deg2rad(horizontal_angle))
	_set_sky_rotation()
	
func save_json():
	var save_data = {
		"path" : get_path(),
		"time_of_day" : time_of_day,
	}
	return save_data
	

func load_json(data_dict):
	time_of_day = data_dict["time_of_day"]
	print(data_dict)
	_on_Time_Of_Day_value_changed(time_of_day)

func _on_SkyTexture_sky_updated():
	sky_texture.copy_to_environment(environment)
