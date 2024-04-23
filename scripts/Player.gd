extends KinematicBody

export var speed = 10
export var sprint_speed = 30
export var crouch_speed = 5
export var acceleration = 5
export var gravity = 0.98
export var jump_power = 30
export var mouse_sensitivity = 0.3
export var crouch_offset = -0.5

var is_crouching = false  
var is_sprinting = false  

onready var head = $Head
onready var camera = $Head/Camera

var velocity = Vector3()
var camera_x_rotation = 0

var inventory_resource = load("res://scripts/Inventory.gd")
var inventory = inventory_resource.new()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))

		var x_delta = event.relative.y * mouse_sensitivity
		if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90:
			camera.rotate_x(deg2rad(-x_delta))
			camera_x_rotation += x_delta
	

	if Input.is_action_pressed("sprint"):
		is_sprinting = true
	else:
		is_sprinting = false

	if Input.is_action_pressed("crouch"):
		is_crouching = true
	else:
		is_crouching = false


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	var head_basis = head.get_global_transform().basis

	var movement_vector = Vector3()
	if Input.is_action_pressed("movement_forward"):
		movement_vector -= head_basis.z
	if Input.is_action_pressed("movement_backward"):
		movement_vector += head_basis.z
	if Input.is_action_pressed("movement_left"):
		movement_vector -= head_basis.x
	if Input.is_action_pressed("movement_right"):
		movement_vector += head_basis.x

	movement_vector = movement_vector.normalized()
	
	var current_speed = speed
	if is_sprinting:
		current_speed = sprint_speed
	elif is_crouching:
		current_speed = crouch_speed

	velocity = velocity.linear_interpolate(movement_vector * current_speed, acceleration * delta)
	velocity.y -= gravity

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_power

	velocity = move_and_slide(velocity, Vector3.UP)
