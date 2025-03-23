extends CanvasLayer

@export var in_game = true

signal start_conveyors_placing
signal cancel_conveyor_placing
signal conveyor_placing_ended
signal start_destroying
signal cancel_destroying
signal destroying_ended
signal pause_input
signal resume_input
signal start_decorations
signal abort_decorations
signal place_decorations

var decorations_tile = {
	"plant": [4,Vector2i(1,0),"plant.png","plantfocus.png"]
}

var unlocked_decorations = ["plant"]

var ispaused = false
var debug = false
var fps_values: Array = []
@export var max_points: int = 100
@export var graph_height: int = 100
@export var update_interval: float = 0.05
var time_elapsed: float = 0.0
var is_placing_conveyors = false
var is_placing_removing: bool = false
var is_placing_decorations :bool = false
var is_in_tree: bool = false
var window: Control
var currentile = []

@onready var line: Line2D = $DEBUG/Line2D

func _ready():
	if in_game:
		$AnimationPlayer.play("everythingappear")

func hide_hud(placeseconddock:bool = false):
	if placeseconddock == false:
		$AnimationPlayer.play_backwards("dockappear")
	else:
		$AnimationPlayer.play("dockreplaceandgoaway")

func _unhandled_input(event):
	if event.is_action_pressed("debug"):
		debug = !debug
	if event is InputEventKey and event.is_action_pressed("pause"):
		if not is_placing_conveyors and not is_placing_removing and not is_in_tree and not is_placing_decorations:
			toggle_pause()
		elif is_placing_conveyors:
			emit_signal("cancel_conveyor_placing")
			conveyor_aborted()
			window.close()
		elif is_placing_removing:
			emit_signal("cancel_destroying")
			destroying_aborted()
			window.close()
		elif is_in_tree:
			$AnimationPlayer.play_backwards("techtree")
			is_in_tree = false
			emit_signal("resume_input")
		elif is_placing_decorations:
			emit_signal("abort_decorations")
			decoration_aborted()
			window.close()

func _on_conveyorbtn_pressed():
	hide_hud()
	window = add_confirm_dialog(conveyor_aborted, conveyor_placed)
	start_conveyors_placing.emit()
	is_placing_conveyors = true

func add_confirm_dialog(func_abort, func_config):
	var scene = load("res://scenes/window.tscn")
	var confirmation = scene.instantiate()
	confirmation.accepted.connect(func_config)
	confirmation.cancelled.connect(func_abort)
	$"top-right".add_child(confirmation)
	return confirmation

func conveyor_aborted():
	$AnimationPlayer.play("dockappear")
	cancel_conveyor_placing.emit()
	is_placing_conveyors = false

func conveyor_placed():
	$AnimationPlayer.play("dockappear")
	conveyor_placing_ended.emit()
	is_placing_conveyors = false

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
		emit_signal("pause_input") # Block input when paused
	else:
		$AnimationPlayer.play_backwards("pause")
		emit_signal("resume_input") # Unblock input when unpaused

func _on_exitgame_pressed():
	$AnimationPlayer.play_backwards("everythingappear")
	Trans.fadeTransition(load("res://scenes/mainmenu.tscn"))

func destroying_confirmed():
	$AnimationPlayer.play("dockappear")
	destroying_ended.emit()
	is_placing_removing = false

func destroying_aborted():
	$AnimationPlayer.play("dockappear")
	cancel_destroying.emit()
	is_placing_removing = false

func _on_removebtn_pressed():
	hide_hud()
	window = add_confirm_dialog(destroying_aborted, destroying_confirmed)
	start_destroying.emit()
	is_placing_removing = true

func _process(delta):
	$DEBUG.visible = debug
	$DEBUG/Label.text = "FPS : " + str(Engine.get_frames_per_second())
	update_fps_graph(delta)
	Global.convert_money()
	$MoneyContainer/Control/Label.text = str(Global.money) + "$"
	var moneydigits = ($MoneyContainer/Control/Label.text.length() * 50)
	$MoneyContainer/Control/NinePatchRect.position.x = -192.0 - moneydigits
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

func _on_techtree_pressed() -> void:
	is_in_tree = true
	emit_signal("pause_input")
	$AnimationPlayer.play("techtree")

func _on_decorationbtn_pressed() -> void:
	hide_hud(true)
	window = add_confirm_dialog(decoration_aborted, decoration_placed)
	start_decorations.emit()
	is_placing_decorations = true
	add_dock_items()

func decoration_aborted():
	$AnimationPlayer.play_backwards("dockreplaceandgoaway")
	print("aborted it should work now :hd:")
	emit_signal("abort_decorations")
	is_placing_decorations = false

func decoration_placed():
	$AnimationPlayer.play_backwards("dockreplaceandgoaway")
	place_decorations.emit()
	is_placing_removing = false

func add_dock_items():
	for i in $availableitemdock/Control/ScrollContainer/HBoxContainer.get_children().size():
		$availableitemdock/Control/ScrollContainer/HBoxContainer.get_children()[i].queue_free()
	for each in unlocked_decorations.size():
		var itemname = unlocked_decorations[each]
		var itemcard = load("res://scenes/buttondock.tscn")
		var itembutton = itemcard.instantiate()
		itembutton.texture = decorations_tile[itemname][2]
		itembutton.focus_texture = decorations_tile[itemname][3]
		itembutton.item_name = itemname
		itembutton.pressed.connect(_on_item_pressed.bind(itemname))
		$availableitemdock/Control/ScrollContainer/HBoxContainer.add_child(itembutton)
	if $availableitemdock/Control/ScrollContainer/HBoxContainer.size.x < $availableitemdock/Control/ScrollContainer.size.x:
		$availableitemdock/Control/Container.size.x = $availableitemdock/Control/ScrollContainer/HBoxContainer.size.x + 20
	else:
		$availableitemdock/Control/Container.size.x = 68

func _on_item_pressed(itemname):
	currentile = [decorations_tile[itemname][0],decorations_tile[itemname][1]]
	
