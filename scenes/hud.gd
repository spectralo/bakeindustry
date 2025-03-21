extends CanvasLayer

@export var in_game = true

signal start_conveyors_placing
signal cancel_conveyor_placing
signal conveyor_placing_ended
signal start_destroying
signal cancel_destroying
signal destroying_ended

var ispaused = false
var debug = false
var fps_values: Array = []
@export var max_points: int = 100
@export var graph_height: int = 100
@export var update_interval: float = 0.05
var time_elapsed: float = 0.0

@onready var line: Line2D = $DEBUG/Line2D

func _ready():
	if in_game:
		$AnimationPlayer.play("everythingappear")

func hide_hud():
	$AnimationPlayer.play_backwards("dockappear")

func _unhandled_input(event):
	if event.is_action_pressed("debug"):
		debug = !debug
		print("debug is : " + str(debug))
	if event is InputEventKey and event.is_action_pressed("pause"):
		toggle_pause()

func _on_conveyorbtn_pressed():
	hide_hud()
	add_confirm_dialog(conveyor_aborted, conveyor_placed)
	start_conveyors_placing.emit()

func add_confirm_dialog(func_abort, func_config):
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
	ispaused = true
	$AnimationPlayer.play("pause")

func _on_exit_pressed():
	ispaused = false
	$AnimationPlayer.play_backwards("pause")

func toggle_pause():
	ispaused = !ispaused
	if ispaused:
		$AnimationPlayer.play("pause")
	else:
		$AnimationPlayer.play_backwards("pause")
#
func _on_exitgame_pressed():
	get_tree().quit()

func destroying_confirmed():
	$AnimationPlayer.play("dockappear")
	destroying_ended.emit()

func destroying_aborted():
	$AnimationPlayer.play("dockappear")
	cancel_destroying.emit()

func _on_removebtn_pressed():
	hide_hud()
	add_confirm_dialog(destroying_aborted, destroying_confirmed)
	start_destroying.emit()

func _process(delta):
	$DEBUG.visible = debug
	$DEBUG/Label.text = "FPS : " + str(Engine.get_frames_per_second())
	update_fps_graph(delta)
	Global.convert_money()
	$MoneyContainer/Control/Label.text = str(Global.money) + "$"
	var moneydigits = ($MoneyContainer/Control/Label.text.length()*50)
	$MoneyContainer/Control/NinePatchRect.position.x = -192.0-moneydigits
	print(moneydigits)
	$MoneyContainer/Control/NinePatchRect.size.x = moneydigits
	
func update_fps_graph(delta):
	time_elapsed += delta
	if time_elapsed >= update_interval:
		fps_values.append(Engine.get_frames_per_second())
		if fps_values.size() > max_points:
			fps_values.pop_front()
		draw_graph()
		time_elapsed = 0.0

func draw_graph():
	line.clear_points()
	var min_fps = 0
	var max_fps = 120
	for i in range(fps_values.size()):
		var normalized_fps = (fps_values[i] - min_fps) / float(max_fps - min_fps)
		var y = graph_height - (normalized_fps * graph_height)
		line.add_point(Vector2(i * (line.get_parent().size.x / max_points) * 5, y))
