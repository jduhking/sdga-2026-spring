class_name Finger
extends Node2D

const SPEED : float = 10
const CLOSE_IN_SPEED : float = 2.5
@export var max_flick_strength : float = 500
var flick_strength : float = 0
@export var max_hold_time : float = 0.5
@export var draw_near_time : float = 0.2
const still_offset : float = 22
var hold_elapsed_time : float = 0
var draw_near_elapsed_time : float = 0
const closeness_threshold : float = 4
const farness_threshold : float = 32
enum STATE { NONE, HOLD, RELEASED }
var state : STATE = STATE.NONE
var dir_to_ball : int = 1
var mouse_pos_prev_frame : Vector2
var move_threshold : float = 2
const move_to_ball_threshold : float = 48
@onready var sprite = $Sprite2D
@onready var progress_bar : ProgressBar = $ProgressBar

func change_state(new_state : STATE):
	state = new_state
	match state:
		STATE.NONE:
			pass
		STATE.HOLD:
			pass
		STATE.RELEASED:
			sprite.frame = 1
			GameManager.cam.follow_node = GameManager.ball
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
	GameManager.cam.follow_node = self

func _process(delta: float) -> void:
	dir_to_ball = sign(GameManager.ball.global_position.x - global_position.x) 
	sprite.flip_h = dir_to_ball < 0
	update_state(delta)
	

func move(delta):
	var target = get_global_mouse_position()
	var distance_to_ball = GameManager.ball.global_position.distance_to(global_position)
	var should_draw_near = draw_near_elapsed_time >= draw_near_time
	draw_near_elapsed_time = draw_near_elapsed_time + delta if target.distance_to(mouse_pos_prev_frame) < move_threshold and distance_to_ball <= move_to_ball_threshold else 0
	
	if should_draw_near:
		var ball_target_pos = GameManager.ball.global_position + Vector2.RIGHT * dir_to_ball * -still_offset
		global_position += (ball_target_pos - global_position) * delta * CLOSE_IN_SPEED
	else:
		global_position += (target - global_position) * delta * SPEED
		
	mouse_pos_prev_frame = target
	
