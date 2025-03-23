extends Control

signal accepted
signal cancelled

var is_closing : bool = false

func _ready():
	print("confirm instancied")
	$AnimationPlayer.play("apearing")

func _on_cancel_pressed():
	emit_signal("cancelled")
	close()

func close():
	$AnimationPlayer.play_backwards("apearing")
	is_closing = true

func _on_accept_pressed():
	emit_signal("accepted")
	close()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if is_closing:
		queue_free()
