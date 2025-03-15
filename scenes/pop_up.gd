extends Control

func _ready():
	pivot_offset.y = size.y
	$AnimationPlayer.play("popup")
