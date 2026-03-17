class_name Ball
extends CharacterBody2D

@export var gravity: float = 1200.0
@export var mass: float = 1.0
@onready var sprite : Sprite2D = $Sprite2D
@onready var original_snap_length = floor_snap_length
const RADIUS = 16.0
const grab_threshold: float = 24.0

var rotational_speed: float = 0.0
@export var friction : float = 150
var picked: bool = false

var last_floor_normal : Vector2 = Vector2.RIGHT
var last_slope_parallel : Vector2 = Vector2.ZERO


func _ready() -> void:
	GameManager.ball = self
	# Crucial for slope movement: keeps the ball from "bouncing" off slopes
	floor_snap_length = 16.0 


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
	if Input.is_action_just_pressed("right_click") and get_global_mouse_position().distance_to(global_position) <= grab_threshold:
		picked = true
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		var floor_normal = get_floor_normal()
		var slope_parallel = floor_normal.rotated(PI/2)

		# Log every surface we're on
		print("SURFACE | normal: ", floor_normal.snapped(Vector2(0.01, 0.01)), 
			" | slope_parallel: ", slope_parallel.snapped(Vector2(0.01, 0.01)),
			" | vel: ", velocity.snapped(Vector2(0.1, 0.1)),
			" | speed: ", velocity.length())

		if (slope_parallel.y <= -0.99 and last_slope_parallel.y > -0.99) or (slope_parallel.y > -0.99 and last_slope_parallel.y <= -0.99):
			var current_speed = velocity.length()
			var dir = sign(velocity.dot(slope_parallel))
			if dir == 0: dir = 1.0
			var old_vel = velocity
			velocity = slope_parallel * dir * current_speed
			print("REDIRECT | old_vel: ", old_vel.snapped(Vector2(0.1, 0.1)), 
				" | new_vel: ", velocity.snapped(Vector2(0.1, 0.1)),
				" | dir: ", dir,
				" | speed: ", current_speed)

		last_floor_normal = floor_normal
		last_slope_parallel = slope_parallel

		var gravity_pull = Vector2.DOWN.dot(slope_parallel) * gravity
		velocity += slope_parallel * gravity_pull * delta

		var ground_speed = get_real_velocity().dot(slope_parallel)
		rotational_speed = ground_speed / RADIUS

		var speed_along_slope = velocity.dot(slope_parallel)
		var friction_delta = friction * delta
		var new_speed = move_toward(speed_along_slope, 0.0, friction_delta)
		velocity = velocity - slope_parallel * (speed_along_slope - new_speed)

		print("POST_FRICTION | vel: ", velocity.snapped(Vector2(0.1, 0.1)), 
			" | speed_along_slope: ", speed_along_slope,
			" | new_speed: ", new_speed)

		$RayCast2D.target_position = slope_parallel * 43

	else:
		#last_slope_parallel = Vector2.ZERO
		print("AIRBORNE | vel: ", velocity.snapped(Vector2(0.1, 0.1)))

	move_and_slide()
	sprite.rotate(rotational_speed * delta)
