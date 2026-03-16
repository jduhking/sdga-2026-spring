extends Node

var tilemap : TileMapLayer
var cam : MainCamera
var ball : Ball
var goal : Goal
var finger : Finger
var current_level : Level
@export var DEBUG_ON : bool = false



const LEVELS = [
	"res://Levels/level_1.tscn",
	"res://Levels/level_2.tscn",
	"res://Levels/level_3.tscn",
]
enum GAMESTATE { NONE, GAME, GAMEOVER}
var game_state : GAMESTATE = GAMESTATE.NONE

var current_level_index: int = 0

func change_state(new_state : GAMESTATE):
	game_state = new_state
	match game_state:
		GAMESTATE.NONE:
			pass
		GAMESTATE.GAME:
			goal.progress_complete.connect(_on_level_complete)
		GAMESTATE.GAMEOVER:
			restart_level()

func _process(delta: float) -> void:
	update_state(delta)
	
func _on_level_complete():
	restart_level()
			
func update_state(delta):
	match game_state:
		GAMESTATE.GAME:
			if Input.is_action_just_pressed("restart"):
				restart_level()
			if Input.is_action_just_pressed("slow") and DEBUG_ON:
				Engine.time_scale = 0.1 if Engine.time_scale == 1 else 1
			if current_level and ball.global_position.y > current_level.max_y + 32:
				change_state(GAMESTATE.GAMEOVER)
func load_level(index: int) -> void:
	current_level_index = clampi(index, 0, LEVELS.size() - 1)
	get_tree().change_scene_to_file(LEVELS[current_level_index])


func next_level() -> void:
	if current_level_index + 1 < LEVELS.size():
		load_level(current_level_index + 1)
	else:
		load_main_menu()  # or credits, etc.


func restart_level() -> void:
	get_tree().change_scene_to_file(LEVELS[current_level_index])


func load_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)


func load_main_menu() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
