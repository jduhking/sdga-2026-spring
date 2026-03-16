class_name Level
extends Node2D

@onready var min_x : float = $Bounds/MinX.global_position.x
@onready var max_x : float = $Bounds/MaxX.global_position.x
@onready var min_y : float = $Bounds/MinY.global_position.y
@onready var max_y : float = $Bounds/MaxY.global_position.y

func _ready() -> void:
	GameManager.tilemap = $TileMapLayer
	GameManager.change_state(GameManager.GAMESTATE.GAME)
	GameManager.cam.min_x = min_x
	GameManager.cam.max_x = max_x
	GameManager.cam.min_y = min_y
	GameManager.cam.max_y = max_y
