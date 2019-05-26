extends KinematicBody

signal place_object

const GRAVITY = -49
const MAX_SPEED = 10
const JUMP_SPEED = 18
const ACCEL = 4.5
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 80
const HOLDING_OBJECT_ROT_SPEED = 0.2

var MOUSE_SENSITIVITY = 0.05

var vel = Vector3()
var dir = Vector3()
var is_swimming = false
var holding_object = null
var is_crouching = false
var holding_object_angle = 0
var relative_normal = Vector3(0, 0, 0)
var current_target = null
var fly_mode = false
var wielding_item = null

onready var camera = $RotationPivot/Camera
onready var rotation_helper = $RotationPivot
onready var feet_ray = $FeetRay
onready var use_ray = $RotationPivot/Camera/UseRay
onready var ray_tip = $RotationPivot/Camera/RayTip
onready var anim_player = $AnimationPlayer
onready var place_ray = $RotationPivot/Camera/PlaceRay
onready var build_hud = $CanvasLayer/HUD/BuildHUD
onready var blur = $CanvasLayer/HUD/Blur
onready var hand = $RotationPivot/Camera/Hand

var ground_normal = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	build_hud.connect("spawn_build", self, "on_spawn_build")
	blur.blur_out()
	
	
func _physics_process(delta):
	process_input(delta)
	input_mouse_poll()
	process_movement(delta)
	process_use_ray()
	process_place_ray()
	process_holding_object()

func process_input(delta):
	#Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2()
	
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
		
	input_movement_vector = input_movement_vector.normalized()
	
	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	
	#Jumping
	if feet_ray.is_colliding():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	
	if Input.is_action_just_pressed("ui_accept"):
		fly_mode = !fly_mode
	
	if fly_mode:
		if Input.is_action_pressed("ascend"):
			vel.y += 1
		if Input.is_action_pressed("descend"):
			vel.y -= 1
			
	if Input.is_action_just_pressed("build_hud"):
		toggle_build_hud()
		
	if Input.is_action_just_pressed("crouch"):
		toggle_crouch_state()
			
	#Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_mouse_mode()
			

# Sets the raycasts lenght position (RayTip) to, if collinding the collision points. or if not collinding default position. (0, 0, -4.5) 
func process_place_ray():
	if place_ray.is_colliding():
		ray_tip.global_transform.origin = place_ray.get_collision_point()			
	else:
		ray_tip.translation = place_ray.translation + Vector3(0, 0, -4.5)

#Rotates the holding object by the rotation constant decalred in script
func rotate_holding_object(rot):
	holding_object_angle += rot

func look_at_with_y(new_y,v_up):
	#Y vector
	var basis = Basis()
	basis.y=new_y.normalized()
	basis.z=v_up*-1
	basis.x = basis.z.cross(basis.y).normalized();
	#Recompute z = y cross X
	basis.z = basis.y.cross(basis.x).normalized();
	basis.x = basis.x * -1   # <======= ADDED THIS LINE
	basis = basis.orthonormalized() # make sure it is valid 
	return basis



func process_use_ray():
	
	if is_holding_object():
		return
	
	if use_ray.is_colliding():
		var collider = use_ray.get_collider()
		if collider.is_in_group("building") or collider.is_in_group("items"):
			current_target = collider
			current_target.set_targeting(true)
		else:
			if is_interacting_with_target():
				current_target.set_targeting(false)
				current_target = null
			
	elif is_interacting_with_target() and not use_ray.is_colliding():
		current_target.set_targeting(false)
		current_target = null
		


func input_mouse_poll():
	if Input.is_action_just_pressed("left_mouse"):
		if is_holding_object():
			place_holding_object()
		elif is_interacting_with_target():
			if current_target.has_method("use"):
				current_target.use()
			if current_target.has_method("pick_up"):
				wield_item(current_target.pick_up())
			
	elif Input.is_action_just_pressed("right_mouse"):
		if is_holding_object():
			discard_holding_object()
		elif is_interacting_with_target():
			current_target.get_parent().remove_child(current_target)
			hold_object(current_target)
			current_target = null
			

func wield_item(item):
	if wielding_item == null:
		wielding_item = item
		wielding_item.rotation_degrees = Vector3(65, -65, 0)
		hand.add_child(wielding_item)
	
func process_holding_object():
	
	if is_holding_object():
		
		if place_ray.is_colliding():
			holding_object.global_transform.origin = place_ray.get_collision_point()
			var look_at = look_at_with_y(place_ray.get_collision_normal(), Vector3.UP)
			var facing = Basis(Vector3(0, holding_object_angle, 0))
			holding_object.global_transform.basis = look_at * facing
		else:
			holding_object.global_transform = ray_tip.global_transform
			var facing = Basis(Vector3(0, holding_object_angle, 0))
			holding_object.global_transform.basis *= facing

func toggle_build_hud():
	build_hud.visible = not build_hud.visible
	toggle_mouse_mode()
	if build_hud.visible:
		blur.blur_in()
	else:
		blur.blur_out()
	
		

func toggle_mouse_mode():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func toggle_crouch_state():
	if !is_crouching:
		anim_player.play("crouch_down")
	else:
		anim_player.play("crouch_up")
	is_crouching = !is_crouching

# Gives the palyer an objec to hold
func hold_object(object):
	if is_holding_object():
		holding_object.queue_free()
	# if interacting with a target with useray, reset it.
	if is_interacting_with_target():
		current_target.set_targeting(false)
		current_target = null
	
	holding_object = object
	use_ray.add_exception(holding_object)
	ray_tip.add_child(object)
	var collision_shape = holding_object.get_node("CollisionShape")
	if collision_shape != null:
		collision_shape.disabled = true
	if holding_object is RigidBody:
		holding_object.sleeping = true

# add to this function whenever a new state should make the player freeze...
func is_player_freezed():
	return build_hud.visible

# Emits a signal that the world connects to, passes the holding object and its transform
func place_holding_object():
	if is_holding_object():
		if holding_object is RigidBody:
			holding_object.sleeping = false
		var object_transform = Transform(holding_object.global_transform)
		ray_tip.remove_child(holding_object)
		emit_signal("place_object", holding_object, object_transform)
		var collision_shape = holding_object.get_node("CollisionShape")
		if collision_shape != null:
			collision_shape.disabled = false
	
		holding_object = null
		use_ray.clear_exceptions()
		
	
#Removes the object that the user holds infront of him.
func discard_holding_object():
	if is_holding_object():
		holding_object.queue_free()
		holding_object = null

#player chose a building to build
func on_spawn_build(path):
	var instance = load(path).instance()
	hold_object(instance)
	toggle_build_hud()

func is_holding_object():
	return holding_object != null

func is_interacting_with_target():
	return current_target != null

func process_movement(delta):
	
	if is_player_freezed():
		return
	
	if translation.y < -0.5:
		is_swimming = true
	else:
		is_swimming = false
	
	dir.y = 0
	dir = dir.normalized()
	
	var gravity = GRAVITY
	var max_speed = MAX_SPEED
	
	if is_swimming:
		gravity = -gravity 
		max_speed = max_speed * 0.5
	elif is_crouching:
		max_speed = max_speed * 0.25
	
	if not fly_mode:
		vel.y += delta * gravity
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	target *= max_speed
	
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	
func _input(event):
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
			self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
			var camera_rot = rotation_helper.rotation_degrees
			camera_rot.x = clamp(camera_rot.x, -70, 70)
			rotation_helper.rotation_degrees = camera_rot
		
		if is_holding_object() and event is InputEventMouseButton:
			if event.button_index == BUTTON_WHEEL_UP:
				rotate_holding_object(HOLDING_OBJECT_ROT_SPEED)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				rotate_holding_object(-HOLDING_OBJECT_ROT_SPEED)
		
	

func save_json():
	var save_data = {
		"path" : get_path(),
		"translation" : Utils.vec3_to_dict(translation),
		"rotation" : Utils.vec3_to_dict(rotation_degrees),
		"scale" : Utils.vec3_to_dict(scale),
		"rotation_helper_rotation" : Utils.vec3_to_dict(rotation_helper.rotation_degrees),
	
	}
	return save_data
	

func load_json(data_dict):
	translation = Utils.dict_to_vec3(data_dict["translation"])
	rotation_degrees = Utils.dict_to_vec3(data_dict["rotation"])
	scale = Utils.dict_to_vec3(data_dict["scale"])
	rotation_helper.rotation_degrees = Utils.dict_to_vec3(data_dict["rotation_helper_rotation"])

	