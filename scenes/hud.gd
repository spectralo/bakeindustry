extends CanvasLayer

@export var in_game = true

signal start_conveyors_placing
signal cancel_conveyor_placing
signal conveyor_placing_ended

signal start_destroying
signal cancel_destroying
signal destroying_ended


var ispaused = false

func _ready():
	if in_game:
		$AnimationPlayer.play("everythingappear")

func hide_hud():
	$AnimationPlayer.play_backwards("dockappear")
	
func _unhandled_input(event):
	if event is InputEventKey and event.is_action_pressed("pause"):
		toggle_pause()


func _on_conveyorbtn_pressed():
	hide_hud()
	add_confirm_dialog(conveyor_aborted,conveyor_placed)
	start_conveyors_placing.emit()
	
func add_confirm_dialog(func_abort,func_config):
	var scene = load("res://scenes/window.tscn")
	var confirmation = scene.instantiate()
	confirmation.accepted.connect(func_config)
	confirmation.cancelled.connect(func_abort)
	$"top-right".add_child(confirmation)
	
	
func conveyor_aborted():
	$AnimationPlayer.play("dockappear")
	cancel_conveyor_placing.emit()

func conveyor_placed():
	$AnimationPlayer.play("dockappear")
	conveyor_placing_ended.emit()


func _on_pause_pressed():
	ispaused=true
	$AnimationPlayer.play("pause")


func _on_exit_pressed():
	ispaused=false
	$AnimationPlayer.play_backwards("pause")

func toggle_pause():
	if ispaused == true:
		$AnimationPlayer.play_backwards("pause")
		ispaused = false
	else:
		$AnimationPlayer.play("pause")
		ispaused = true


func _on_exitgame_pressed():
	get_tree().quit()

func destroying_confirmed():
	$AnimationPlayer.play("dockappear")
	emit_signal("destroying_ended")

func destroying_aborted():
	$AnimationPlayer.play("dockappear")
	emit_signal("cancel_destroying")

func _on_removebtn_pressed():
	hide_hud()
	add_confirm_dialog(destroying_aborted,destroying_confirmed)
	start_destroying.emit()
	
