class_name MainCamera
extends Camera2D

var follow_node : Node2D

var min_x : float = 0
var max_x : float = 320
var min_y : float = -180
var max_y : float = 0
var last_mouse_pos : Vector2 
var panning : bool = true
var holding : bool = false
@export var hold_cam_offset : float = 64
@export var hold_pan_time : float = 0.225
var tween_point : Vector2 = Vector2.ZERO
var tween : Tween 
const PAN_SPEED : float = 120

signal pan_complete 

func _ready():
	GameManager.cam = self
	last_mouse_pos = get_viewport().get_mouse_position()

func init():
	GameManager.finger.started_holding.connect(_on_finger_started_holding)
	GameManager.finger.stopped_holding.connect(_on_finger_stopped_holding)
	
func _on_finger_started_holding():
	var half_res = get_viewport_rect().size * 0.5
	holding = true
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	var finger_position = GameManager.finger.global_position
	var set_position = finger_position + Vector2.RIGHT * sign(GameManager.ball.global_position.x - finger_position.x) * hold_cam_offset
	var x = clampf(set_position.x, min_x + half_res.x, max_x - half_res.x)
	var y = clampf(set_position.y, min_y + half_res.y, max_y - half_res.y)
	
	tween.tween_property(self, "global_position", set_position, hold_pan_time)

func _on_finger_stopped_holding():
	if tween:
		tween.kill()
	holding = false
	GameManager.cam.follow_node = GameManager.ball
	
func pan_to_target(target : Vector2):
	panning = true
	var start_pos = global_position
	tween_point = start_pos
	
	var pan_time : float = target.distance_to(tween_point) / PAN_SPEED
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "tween_point", target, pan_time)
	tween.tween_property(self, "tween_point", start_pos, pan_time)
	tween.tween_callback(pan_complete.emit)
	
	

func _physics_process(delta: float) -> void:
	var half_res = get_viewport_rect().size * 0.5
	if !holding:
		if follow_node or panning:
			var follow_pos = follow_node.global_position if !panning else tween_point
			var x = clampf(follow_pos.x, min_x + half_res.x, max_x - half_res.x)
			var y = clampf(follow_pos.y, min_y + half_res.y, max_y - half_res.y)
			global_position = Vector2(x, y)



func _input(event):
	if follow_node or panning or holding:
		return
	if event is InputEventMouseMotion:
		var half_res = get_viewport_rect().size * 0.5
		var screen_mouse = get_global_mouse_position()
		var new_pos = Vector2(
			clampf(screen_mouse.x - half_res.x, min_x, max_x - half_res.x * 2),
			clampf(screen_mouse.y - half_res.y, min_y, max_y - half_res.y * 2)
		)
		global_position = new_pos + half_res
