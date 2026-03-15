class_name Level
extends Node2D


func _ready() -> void:
	GameManager.tilemap = $TileMapLayer
	GameManager.change_state(GameManager.GAMESTATE.GAME)
