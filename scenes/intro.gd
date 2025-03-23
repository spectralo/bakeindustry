extends Control

func _on_animated_sprite_2d_animation_finished() -> void:
	var mainmenu = load("res://scenes/mainmenu.tscn")
	Trans.fadeTransition(mainmenu)

func _on_timer_timeout() -> void:
	$Control/AnimatedSprite2D.play("default")
