class_name Finger
extends Node2D

@export var SPEED : float = 120
@export var FAR_SPEED : float = 1000
@export var CLOSE_IN_SPEED : float = 50
@export var max_flick_strength : float = 500
var flick_strength : float = 0
@export var max_hold_time : float = 0.5
@export var draw_near_time : float = 0.2
const still_offset : float = 22
var hold_elapsed_time : float = 0
const speedup_threshold : float = 50
var draw_near_elapsed_time : float = 0
const closeness_threshold : float = 4
const farness_threshold : float = 32
enum STATE { NONE, HOLD, RELEASED }
var state : STATE = STATE.NONE
var dir_to_ball : int = 1
var mouse_pos_prev_frame : Vector2
var move_threshold : float = 2
var target : Vector2
var current_speed : float = 0
@export var SPEEDUP = 120
const move_to_ball_threshold : float = 48
@onready var sprite = $Sprite2D
@onready var progress_bar : ProgressBar = $ProgressBar

signal started_holding
signal stopped_holding

func change_state(new_state : STATE):
	state = new_state
	match state:
		STATE.NONE:
			pass
		STATE.HOLD:
			started_holding.emit()
		STATE.RELEASED:
			stopped_holding.emit()
			sprite.frame = 1
			GameManager.ball.velocity.x += flick_strength * dir_to_ball


func update_state(delta):
	match state:
		STATE.NONE:
			move(delta)
			if Input.is_action_just_pressed("left_click"):
				var dist_ball = global_position.distance_to(GameManager.ball.global_position)
				if GameManager.ball and dist_ball <= farness_threshold and dist_ball >= closeness_threshold:
					change_state(STATE.HOLD)
		STATE.HOLD:
			hold_elapsed_time += delta
			var perc = clampf(hold_elapsed_time / max_hold_time, 0,1)
			flick_strength = lerpf(0, max_flick_strength, perc)
			progress_bar.value = perc
			if hold_elapsed_time >= max_hold_time or !Input.is_action_pressed("left_click"):
				change_state(STATE.RELEASED)
			move(delta)
		STATE.RELEASED:
			pass
			
func _ready():
	GameManager.finger = self
	set_process(false)

func _process(delta: float) -> void:
	dir_to_ball = sign(GameManager.ball.global_position.x - global_position.x) 
	sprite.flip_h = dir_to_ball < 0
	update_state(delta)
	

func move(delta):
	var screen_mous_pos = get_viewport().get_mouse_position()
	var mouse_delta = screen_mous_pos.distance_to(mouse_pos_prev_frame)
	var moved_passed_threshold : bool = mouse_delta < move_threshold
	target = get_global_mouse_position() if moved_passed_threshold else target
	var distance_to_ball = GameManager.ball.global_position.distance_to(global_position)
	var should_draw_near = draw_near_elapsed_time >= draw_near_time
	draw_near_elapsed_time = draw_near_elapsed_time + delta if moved_passed_threshold and distance_to_ball <= move_to_ball_threshold else 0
	var mouse_distance = target.distance_to(global_position)
	if should_draw_near:
		var ball_target_pos = GameManager.ball.global_position + Vector2.RIGHT * dir_to_ball * -still_offset
		current_speed = CLOSE_IN_SPEED
		global_position = global_position.move_toward(ball_target_pos, delta * CLOSE_IN_SPEED)
	else:
		var should_speed_up : bool = mouse_distance > speedup_threshold and moved_passed_threshold
		if !should_speed_up:
			current_speed = SPEED
		else:
			current_speed = move_toward(SPEED, FAR_SPEED, delta * SPEEDUP)
		global_position = global_position.move_toward(target, delta * current_speed)
		
	mouse_pos_prev_frame = screen_mous_pos
	
