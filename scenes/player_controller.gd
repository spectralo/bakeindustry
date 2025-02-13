extends Node2D

@export var SPEED : float = 600
@export var ZOOM : float = 0.5
var target_zoom : float = ZOOM
var util_layer : TileMapLayer
var ground_layer : TileMapLayer
var conveyor_layer : TileMapLayer
var is_placing_conveyors = true
var last_conveyor_point : Vector2i = Vector2i.ZERO
var conveyors_array : Array = []

var conveyors_textures = {
	"up": Vector2i(0,2),
	"down": Vector2i(0,0),
	"left": Vector2i(0,6),
	"right": Vector2i(0,4),
	"up_left" : Vector2i(0,16) ,
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
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if is_placing_conveyors:
				conveyors(world_pos, true)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = clamp(target_zoom + 0.2, 0.5, 10)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = clamp(target_zoom - 0.2, 0.5, 10)

func _ready() -> void:
	util_layer = get_tree().root.find_child("UtilsLayer", true, false)
	ground_layer = get_tree().root.find_child("GroundLayer", true, false)
	conveyor_layer = get_tree().root.find_child("MachineLayer",true,false)

func conveyors(event_pos, remove: bool):
	var local_util_pos = util_layer.to_local(event_pos)
	
	var local_ground_pos = ground_layer.to_local(event_pos)
	var cell_ground_position = ground_layer.local_to_map(local_ground_pos)
	
	if not last_conveyor_point == cell_ground_position:
		if ground_layer.get_cell_source_id(cell_ground_position) != -1:
			if last_conveyor_point == Vector2i.ZERO or last_conveyor_point.x == cell_ground_position.x or last_conveyor_point.y == cell_ground_position.y:
				util_layer.set_cell(cell_ground_position,3,Vector2i(0,0),0)
				last_conveyor_point = cell_ground_position
				conveyors_array.append(cell_ground_position)
			
func generate_conveyors(pos_array:Array=conveyors_array):
	print(pos_array)
	var last_direction = ""
	for i in range(pos_array.size()):
		
		var set_the_first_one = false
		if i == 0:
			set_the_first_one = true
			
		if not i == pos_array.size()-1:
			var direction = define_conveyor_name(pos_array[i],pos_array[i+1])
			if not i == pos_array.size()-1 and i != 0:
				print("Placing "+str(last_direction+"_"+direction))
				conveyor_layer.set_cell(pos_array[i],2,conveyors_textures[last_direction+"_"+direction])
			fill_between(pos_array[i],pos_array[i+1],conveyors_textures[define_conveyor_name(pos_array[i],pos_array[i+1])],set_the_first_one)
			
			last_direction = define_conveyor_name(pos_array[i],pos_array[i+1])
	conveyor_layer.set_cell(pos_array[pos_array.size()-1],2,conveyors_textures[last_direction])
	cancel_conveyor_draw()
		
func fill_between(pos1: Vector2i, pos2: Vector2i, tile: Vector2i, set_the_first_one:bool=false):
	var dx = abs(pos2.x - pos1.x)
	var dy = abs(pos2.y - pos1.y)
	var sx = 1 if pos1.x < pos2.x else -1
	var sy = 1 if pos1.y < pos2.y else -1
	var err = dx - dy
	
	var current_pos = pos1
	while current_pos != pos2:
		if current_pos != pos1 and current_pos != pos2:
			conveyor_layer.set_cell(current_pos,2,tile)
		
		var e2 = err * 2
		if e2 > -dy:
			err -= dy
			current_pos.x += sx
		if e2 < dx:
			err += dx
			current_pos.y += sy
			
	if set_the_first_one:
		conveyor_layer.set_cell(pos1,2,tile)

func define_conveyor_name(pos1:Vector2i,pos2:Vector2i):
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
