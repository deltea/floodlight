extends CharacterBody3D

@export var max_speed = 5
@export var deceleration = 50
@export var acceleration = 100
@export var cam_tilt = 0

@export var jump_height = 1.0
@export var cam_sensitivity = 1
@export var gravity = 9.8

@export var speedlines: ColorRect

@onready var cam: Camera3D = $Pivot/Camera
@onready var pivot: Node3D = $Pivot

var dir = Vector3.ZERO
var dash_dir = Vector3.ZERO
var is_dashing = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	speedlines.visible = false
	pivot.position.y = 0.5

func _process(dt: float) -> void:
	speedlines.visible = is_dashing

func _physics_process(dt: float):
	if not is_on_floor():
		velocity.y -= gravity * dt

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = sqrt(4 * jump_height * gravity)

	var input = Input.get_vector("left", "right", "forward", "backward")
	dir = (pivot.transform.basis * Vector3(input.x, 0, input.y)).normalized()
	if Input.is_action_just_pressed("dash") and dir != Vector3.ZERO:
		$DashTimer.start()
		is_dashing = true
		dash_dir = dir

	if is_dashing:
		velocity.x = dash_dir.x * 50
		velocity.z = dash_dir.z * 50
		velocity.y = 0
	else:
		if dir:
			velocity.x = move_toward(velocity.x, dir.x * max_speed, acceleration * dt)
			velocity.z = move_toward(velocity.z, dir.z * max_speed, acceleration * dt)
		else:
			velocity.x = move_toward(velocity.x, 0, deceleration * dt)
			velocity.z = move_toward(velocity.z, 0, deceleration * dt)

	if input.x:
		cam.rotation_degrees.z = move_toward(cam.rotation_degrees.z, -input.x * cam_tilt, 40 * dt)
	else:
		cam.rotation_degrees.z = move_toward(cam.rotation_degrees.z, 0, 40 * dt)

	move_and_slide()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			pivot.rotate_y(-event.relative.x * 0.002)
			cam.rotate_x(-event.relative.y * 0.002)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	velocity.x = dash_dir.x * 20
	velocity.z = dash_dir.z * 20
	velocity.y = 0
