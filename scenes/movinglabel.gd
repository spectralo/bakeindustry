extends Label

const SPEED : int = 500

func _process(delta: float) -> void:
	position.x -= SPEED*delta


func _on_timer_timeout() -> void:
	queue_free()
