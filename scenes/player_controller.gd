extends Node2D

@export var SPEED : float = 600
@export var ZOOM : float = 0.5
var target_zoom : float = ZOOM
var util_layer : TileMapLayer
var ground_layer : TileMapLayer
var conveyor_layer : TileMapLayer
var is_placing_conveyors = false
var last_conveyor_point : Vector2i = Vector2i.ZERO
var conveyors_array : Array = []
var is_destroying = false
var destroyed_tiles = []
var pathContainer : Node2D


signal error(message)

var conveyors_textures = {
	"up": Vector2i(0,2),
	"down": Vector2i(0,0),
	"left": Vector2i(0,6),
	"right": Vector2i(0,4),
	"up_left" : Vector2i(0,16),
	"up_right" : Vector2i(0,20),
	"down_right": Vector2i(0,8),
	"down_left": Vector2i(0,10),
	"left_down": Vector2i(0,18),
	"left_up": Vector2i(0,22),
	"right_down": Vector2i(0,12),
	"right_up" : Vector2i(0,14),
	"up_up": Vector2i(0,2),
	"down_down": Vector2i(0,0),
	"left_left": Vector2i(0,6),
	"right_right": Vector2i(0,4),
}


func _process(delta):
	SPEED = 2000 / (log($Camera2D.zoom.x + 1))
	var velocity = Input.get_vector("left", "right", "up", "down")
	position += SPEED * velocity * delta

	ZOOM += (target_zoom - ZOOM) * 0.1
	$Camera2D.zoom = Vector2(ZOOM, ZOOM)
	

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mouse_pos = event.position
		var world_pos = $Camera2D.get_canvas_transform().affine_inverse() * mouse_pos
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_placing_conveyors:
				conveyors(world_pos, false)
			if is_destroying:
				destroy(world_pos,false)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if is_placing_conveyors:
				conveyors(world_pos, true)
			if is_destroying:
				destroy(world_pos,false)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = clamp(target_zoom + 0.2, 0.5, 10)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = clamp(target_zoom - 0.2, 0.5, 10)
		

	

func _ready() -> void:
	util_layer = get_tree().root.find_child("UtilsLayer", true, false)
	ground_layer = get_tree().root.find_child("GroundLayer", true, false)
	conveyor_layer = get_tree().root.find_child("MachineLayer", true, false)
	pathContainer = get_tree().root.find_child("PathContainer",true,false)
	
	# HUD conveyor placing signal connection
	$HUD.cancel_conveyor_placing.connect(cancel_conveyor_draw)
	$HUD.conveyor_placing_ended.connect(generate_conveyors)
	$HUD.start_conveyors_placing.connect(start_conveyor_placing)
	
	# HUD DESSSTROYING2000 signal connection
	$HUD.start_destroying.connect(start_destroying)
	$HUD.cancel_destroying.connect(abort_destroying)
	$HUD.destroying_ended.connect(apply_destroy)
	
	$HUD.show()

#region conveyors

func start_conveyor_placing():
	is_placing_conveyors = true

func update_candidate_tiles() -> void:
	util_layer.clear()
	
	for cell in conveyors_array:
		util_layer.set_cell(cell, 3, Vector2i(0,0), 0)
		
	if conveyors_array.size() == 0:
		return
		
	var last = conveyors_array[conveyors_array.size() - 1]
	var allowed_dirs = []
	
	if conveyors_array.size() == 1:
		allowed_dirs = [Vector2i(0,-1), Vector2i(0,1), Vector2i(-1,0), Vector2i(1,0)]
	elif conveyors_array.size() >= 2:
		var second_last = conveyors_array[conveyors_array.size() - 2]
		if last.x == second_last.x:
			allowed_dirs = [Vector2i(-1,0), Vector2i(1,0),Vector2i(0, 1)] if last.y > second_last.y else [Vector2i(-1,0), Vector2i(1,0),Vector2i(0, -1)]
		elif last.y == second_last.y:
			allowed_dirs = [Vector2i(1, 0),Vector2i(0,-1), Vector2i(0,1)] if last.x > second_last.x else [Vector2i(-1, 0),Vector2i(0,-1), Vector2i(0,1)]
	
	for dir in allowed_dirs:
		var candidate = last + dir
		while ground_layer.get_cell_source_id(candidate) != -1:
			util_layer.set_cell(candidate, 3, Vector2i(0,2), 0)
			candidate += dir
	
func conveyors(event_pos, remove: bool):
	var local_ground_pos = ground_layer.to_local(event_pos)
	var cell_ground_position = ground_layer.local_to_map(local_ground_pos)
	
	if remove:
		if conveyors_array.size() > 0:
			util_layer.erase_cell(cell_ground_position)
			conveyors_array.remove_at(conveyors_array.size() - 1)
			if conveyors_array.size() > 0:
				last_conveyor_point = conveyors_array[conveyors_array.size() - 1]
			else:
				last_conveyor_point = Vector2i.ZERO
			update_candidate_tiles()
	else:
		if last_conveyor_point == cell_ground_position:
			return
			
		if ground_layer.get_cell_source_id(cell_ground_position) == -1:
			return
		
		if conveyors_array.size() > 0:
			if cell_ground_position.x != last_conveyor_point.x and cell_ground_position.y != last_conveyor_point.y:
				return
			
		if conveyors_array.size() >= 2:
			var second_last = conveyors_array[conveyors_array.size() - 2]
			var last_pt = conveyors_array[conveyors_array.size() - 1]
			
			if second_last.x == last_pt.x and cell_ground_position.x == last_pt.x:
				var old_dir = last_pt.y - second_last.y
				var new_dir = cell_ground_position.y - last_pt.y
				if old_dir * new_dir < 0:
					return
			elif second_last.y == last_pt.y and cell_ground_position.y == last_pt.y:
				var old_dir = last_pt.x - second_last.x
				var new_dir = cell_ground_position.x - last_pt.x
				if old_dir * new_dir < 0:
					return
		
		util_layer.set_cell(cell_ground_position, 3, Vector2i(0,0), 0)
		last_conveyor_point = cell_ground_position
		conveyors_array.append(cell_ground_position)
		update_candidate_tiles()


func generate_conveyors(pos_array: Array = conveyors_array):
	
	if pos_array.size() < 2:
		cancel_conveyor_draw()
		return
	var last_direction = ""
	for i in range(pos_array.size()):
		var set_the_first_one = false
		if i == 0:
			set_the_first_one = true
			
		if i != pos_array.size() - 1:
			var direction = define_conveyor_name(pos_array[i], pos_array[i+1])
			if i != pos_array.size() - 1 and i != 0:
				conveyor_layer.set_cell(pos_array[i], 2, conveyors_textures[last_direction + "_" + direction])
				await get_tree().create_timer(0.05).timeout
			fill_between(pos_array[i], pos_array[i+1], conveyors_textures[define_conveyor_name(pos_array[i], pos_array[i+1])], set_the_first_one)
			last_direction = define_conveyor_name(pos_array[i], pos_array[i+1])
			
	conveyor_layer.set_cell(pos_array[pos_array.size() - 1], 2, conveyors_textures[last_direction])
	cancel_conveyor_draw()
		
	
func fill_between(pos1: Vector2i, pos2: Vector2i, tile: Vector2i, set_the_first_one: bool = false):
	var dx = abs(pos2.x - pos1.x)
	var dy = abs(pos2.y - pos1.y)
	var sx = 1 if pos1.x < pos2.x else -1
	var sy = 1 if pos1.y < pos2.y else -1
	var err = dx - dy
	
	var current_pos = pos1
	while current_pos != pos2:
		if current_pos != pos1 and current_pos != pos2:
			conveyor_layer.set_cell(current_pos, 2, tile)
			await get_tree().create_timer(0.05).timeout
		
		var e2 = err * 2
		if e2 > -dy:
			err -= dy
			current_pos.x += sx
		if e2 < dx:
			err += dx
			current_pos.y += sy
			
	if set_the_first_one:
		conveyor_layer.set_cell(pos1, 2, tile)
		

func define_conveyor_name(pos1: Vector2i, pos2: Vector2i):
	var distancey = pos1.y - pos2.y
	var distancex = pos1.x - pos2.x
	
	if distancex == 0:
		if distancey < 0:
			return "down"
		else:
			return "up"
	elif distancey == 0:
		if distancex < 0:
			return "right"
		else:
			return "left"
			


func cancel_conveyor_draw():
	is_placing_conveyors = false
	util_layer.clear()
	conveyors_array = []
	last_conveyor_point = Vector2i.ZERO

#endregion

#region destroying

func start_destroying():
	is_destroying = true	

func destroy(event_pos,remove:bool):
	var local_ground_pos = ground_layer.to_local(event_pos)
	var cell_ground_position = ground_layer.local_to_map(local_ground_pos)
	if remove:
		if destroyed_tiles.size() == 0:
			return
	else:
		destroyed_tiles.append(cell_ground_position)
	draw_affected_tiles()

func apply_destroy():
	for i in range(destroyed_tiles.size()):
		conveyor_layer.erase_cell(destroyed_tiles[i])
	abort_destroying()
	return


func draw_affected_tiles():
	util_layer.clear()
	for i in range(destroyed_tiles.size()):
		util_layer.set_cell(destroyed_tiles[i], 3, Vector2i(2,2), 0)
	
func abort_destroying():
	util_layer.clear()
	destroyed_tiles = []
	is_destroying = false

#endregion
