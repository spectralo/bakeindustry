extends CanvasLayer

@export var LeftBottomOpened = true


func _on_close_pressed() -> void:
	if LeftBottomOpened:
		$AnimationPlayer.play("BottomLeftGoodbye")
		LeftBottomOpened = false
	else:
		$AnimationPlayer.play_backwards("BottomLeftGoodbye")
		LeftBottomOpened = true
