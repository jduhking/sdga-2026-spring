class_name MainCamera
extends Camera2D

var follow_node : Node2D

func _ready():
	GameManager.cam = self
	
func _physics_process(delta: float) -> void:
	if follow_node:
		global_position = follow_node.global_position
