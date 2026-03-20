class_name Level
extends Node2D

@export var level_index : int = 0
@onready var min_x : float = $Bounds/MinX.global_position.x
@onready var max_x : float = $Bounds/MaxX.global_position.x
@onready var min_y : float = $Bounds/MinY.global_position.y
@onready var max_y : float = $Bounds/MaxY.global_position.y
@onready var cam : MainCamera = $MainCamera

@onready var finger : Finger = $Finger
@onready var goal : Goal = $Goal

func _ready() -> void:
	GameManager.ground_tiles = $Tiles/GroundTiles
	GameManager.frozen_tiles = $Tiles/FrozenTiles
	GameManager.current_level = self
	GameManager.current_level_index = level_index	
	cam.min_x = min_x
	cam.max_x = max_x
	cam.min_y = min_y
	cam.max_y = max_y
	cam.global_position = finger.global_position
	cam.pan_complete.connect(_on_pan_complete)
	if !GameManager.skip_pan:
		cam.pan_to_target(goal.global_position)
	else:
		cam.pan_complete.emit()
	GameManager.cam.init()
	GameManager.change_state(GameManager.GAMESTATE.GAME)
	
func _on_pan_complete():
	cam.panning = false
	finger.set_process(true)
