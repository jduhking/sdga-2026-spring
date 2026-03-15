extends CanvasLayer

@onready var velocity : Label = $Velocity
@onready var rs : Label = $RotationalSpeed
@export var debug_font : Font

func _process(delta: float) -> void:
	if GameManager.ball:
		velocity.text = "%s" % str(GameManager.ball.velocity)
		rs.text = "%.2f" % GameManager.ball.rotational_speed
