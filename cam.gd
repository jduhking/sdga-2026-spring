class_name MainCamera
extends Camera2D

var follow_node : Node2D

var min_x : float = 0
var max_x : float = 320
var min_y : float = -180
var max_y : float = 0

func _ready():
	GameManager.cam = self
	
func _physics_process(delta: float) -> void:
	if follow_node:
		var follow_pos = follow_node.global_position
		var half_res = get_viewport_rect().size * 0.5
		var x = clampf(follow_pos.x, min_x + half_res.x, max_x - half_res.x)
		var y = clampf(follow_pos.y, min_y + half_res.y, max_y - half_res.y)
		global_position = Vector2(x,y)
