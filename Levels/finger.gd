extends Node2D

const SPEED : float = 10
@export var BOOST : float = 500
@onready var sprite = $Sprite2D

func _process(delta: float) -> void:
	var target = get_global_mouse_position()
	global_position += (target - global_position) * delta * SPEED
	var dir_to_ball = sign(GameManager.ball.global_position.x - global_position.x) 
	sprite.flip_h = dir_to_ball < 0
	if Input.is_action_just_pressed("left_click"):
		sprite.frame = 1
		GameManager.ball.velocity.x += BOOST * dir_to_ball
