class_name Goal
extends Area2D

@onready var progress_bar : TextureProgressBar = $TextureProgressBar
var progress : float:
	get():
		return progress
	set(value):
		progress = value
		progress_updated.emit(progress)
		if progress >= 1:
			progress_complete.emit()
		
@export var completion_time : float = 0.4
var elapsed_time : float = 0
		
signal progress_updated(value : float)
signal progress_complete 
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.goal = self
	progress_updated.connect(_on_progress_updated)

func _physics_process(delta: float) -> void:
	if progress < 1:
		var bodies = get_overlapping_bodies()
		if bodies.size() > 0:
			elapsed_time = min(elapsed_time + delta, completion_time)
		else:
			elapsed_time = max(elapsed_time - delta, 0)
			
		var perc = elapsed_time / completion_time
		progress = perc
		progress_bar.value = perc
	
	
	
func _on_progress_updated(value : float):
	progress_bar.value = value
