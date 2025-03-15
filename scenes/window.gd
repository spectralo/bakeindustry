extends Control

signal accepted
signal cancelled

func _ready():
	print("confirm instancied")
	$AnimationPlayer.play("apearing")

func _on_cancel_pressed():
	emit_signal("cancelled")
	close()

func close():
	$AnimationPlayer.play_backwards("apearing")


func _on_accept_pressed():
	emit_signal("accepted")
	close()
