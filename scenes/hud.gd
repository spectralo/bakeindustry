extends CanvasLayer

@export var LeftBottomOpened = true
var debug = false

func _process(delta):
	if get_parent().is_placing_conveyors:
		$BTNCONTAINER.show()
	else:
		$BTNCONTAINER.hide()

func _on_cancel_pressed():
	get_parent().cancel_conveyor_draw()


func _on_validate_pressed():
	get_parent().generate_conveyors()
