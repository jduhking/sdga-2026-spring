class_name DebugLayer
extends CanvasLayer

@onready var velocity : Label = $Velocity
@onready var flick : Label = $FlickStrength
@export var debug_font : Font

func _process(delta: float) -> void:
	if GameManager.ball and GameManager.finger:
		velocity.text = "vel: %s" % str(GameManager.ball.velocity)
		flick.text = "flick: %d" % GameManager.finger.flick_strength
