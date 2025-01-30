extends Node2D

@export var SPEED : float = 350
@export var ZOOM : float = 5
var target_zoom : float = ZOOM

func _process(delta):
	SPEED = 1000 / (log($Camera2D.zoom.x + 1))
	var velocity = Input.get_vector("left","right","up","down")
	position += SPEED * velocity * delta

	ZOOM += (target_zoom - ZOOM) * 0.1
	$Camera2D.zoom = Vector2(ZOOM, ZOOM)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = clamp(target_zoom + 0.5, 2, 25)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = clamp(target_zoom - 0.5, 2, 25)
