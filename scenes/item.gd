extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var goal : Vector2 # goal on a global position
var tilemap : TileMapLayer # the tilemap layer of the conveyors :3
var allowed_tiles : Array = [2] # just a random list of ids


func _ready():
	tilemap = get_tree().get_first_node_in_group("movement")
	goal = position
	
func _physics_process(delta):
	if goal.distance_to(position) < 10:
		define_goal(define_direction())
	
	var direction = (goal - position).normalized()
	velocity = direction * SPEED
	move_and_collide(velocity*delta)
	
func define_goal(direction:String):
	var current_tile = tilemap.to_global(tilemap.local_to_map(position))
	print(current_tile)
	var next_tile : Vector2i
	match direction:
		"down": next_tile = Vector2i(current_tile.x,current_tile.y+1)
		"up": next_tile = Vector2i(current_tile.x,current_tile.y-1)
		"left":next_tile = Vector2i(current_tile.x-1,current_tile.y)
		"righy":next_tile = Vector2i(current_tile.x + 1, current_tile.y)
		_:next_tile = current_tile
	var global_goal = tilemap.to_global(tilemap.map_to_local(next_tile))
	if check_position(next_tile):
		goal = global_goal


func define_direction():
	var current_tile = tilemap.to_global(tilemap.local_to_map(position))
	var data = tilemap.get_cell_tile_data(current_tile)
	var direction : String
	if data:
		direction = data.get_custom_data("direction")
	return direction
	
func check_position(tile:Vector2i):
	for i in range(allowed_tiles.size()):
		if tilemap.get_cell_source_id(tile) == allowed_tiles[i]:
			return true
	return false
	
	
