extends Control

func _ready() -> void:
	$Control/AnimatedSprite2D.play("default")
	

func _on_timer_timeout() -> void:
	Trans.fadeTransition(load("res://scenes/demo.tscn"))
