class_name Ball
extends CharacterBody2D

@export var max_speed: float = 300.0
@export var acceleration: float = 500.0 # Increased for better feel
@export var deceleration: float = 300.0
@export var gravity: float = 1200.0
@export var mass: float = 1.0

const RADIUS = 16.0
const grab_threshold: float = 24.0

var rotational_speed: float = 0.0
var picked: bool = false

func _ready() -> void:
	GameManager.cam.follow_node = self
	GameManager.ball = self
	# Crucial for slope movement: keeps the ball from "bouncing" off slopes
	floor_snap_length = 16.0 
	floor_constant_speed = true

func _physics_process(delta: float) -> void:
	if picked:
		_handle_picked_state()
	else:
		_handle_physics_state(delta)

func _handle_picked_state() -> void:
	if Input.is_action_just_pressed("right_click"):
		picked = false
	else:
		var target = get_global_mouse_position()
		velocity = (target - global_position) * 10
		move_and_slide()
		rotational_speed = 0.0

func _handle_physics_state(delta: float) -> void:
	if Input.is_action_just_pressed("mouse") and get_global_mouse_position().distance_to(global_position) <= grab_threshold:
		picked = true
		return

	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 2. Horizontal Input
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if is_on_floor():
		var floor_normal = get_floor_normal()
		# Create a vector that points perfectly along the slope surface
		var slope_parallel = floor_normal.rotated(PI/2)
		
		# 3. Automatic Slope Gravity (The "Roll" down the hill)
		# We project gravity onto the slope's parallel vector
		var gravity_pull = Vector2.DOWN.dot(slope_parallel) * gravity
		velocity += slope_parallel * gravity_pull * delta
		
		# 4. Handle Movement & Deceleration
		if direction:
			# Move along the slope surface rather than raw world X
			var move_vec = slope_parallel * direction * (1 if slope_parallel.x > 0 else -1)
			velocity = velocity.move_toward(move_vec * max_speed, acceleration * delta)
		else:
			# Friction/Deceleration when no input
			velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		
		# 5. Calculate Rotation based on actual ground travel
		# Rotation = (Linear Velocity / Radius)
		var ground_speed = get_real_velocity().dot(slope_parallel)
		rotational_speed = ground_speed / RADIUS
	else:
		# Air control
		if direction:
			velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)

	# 6. Apply Movement
	move_and_slide()
	
	# 7. Apply Visual Rotation
	rotate(rotational_speed * delta)
