extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var tilemap : TileMapLayer
@export var goal : Vector2i
@export var goal_pos : Vector2
@export var speed = 100
@export var acceleration: float = 5.0

var waiting := false  # Flag to stop movement when blocked

func _ready():
	tilemap = get_tree().get_first_node_in_group("movement")
	set_goal(get_direction())

func _physics_process(delta):
	goal_pos = tilemap.to_global(tilemap.map_to_local(goal))

	# If waiting due to a collision, check if we can move again
	if waiting:
		if can_move_to(goal):  
			waiting = false  # Resume movement
		else:
			return  # Stay in place

	# Move towards goal
	if goal_pos.distance_to(position) < 10:
		set_goal(get_direction())

	var direction = (goal_pos - position).normalized()
	var target_velocity = direction * speed
	velocity = velocity.lerp(target_velocity, acceleration * delta)

	# Check for collisions
	var collision = move_and_collide(velocity * delta)
	if collision:
		waiting = true  # Stop moving if blocked

func get_direction():
	var cell_pos : Vector2i = (tilemap.local_to_map(tilemap.to_local(position)))
	var data : TileData = tilemap.get_cell_tile_data(cell_pos)
	if data:
		return data.get_custom_data("direction")
	return "null"

func set_goal(direction:String):
	var cell_pos = tilemap.local_to_map(tilemap.to_local(position))
	var newgoal : Vector2i

	match direction:
		"bottom": newgoal = Vector2i(cell_pos.x,cell_pos.y+1)
		"up": newgoal = Vector2i(cell_pos.x,cell_pos.y-1)
		"left": newgoal = Vector2i(cell_pos.x-1,cell_pos.y)
		"right": newgoal = Vector2i(cell_pos.x+1,cell_pos.y)
		_: newgoal = cell_pos  # Stay in place if no valid direction

	# Check if the new goal is valid
	if can_move_to(newgoal):
		goal = newgoal
	else:
		goal = cell_pos  # Stay in place
		waiting = true  # Mark as waiting

func can_move_to(target_pos: Vector2i) -> bool:
	var data = tilemap.get_cell_tile_data(target_pos)
	if data:
		var acceptItem = data.get_custom_data("acceptItem")
		return acceptItem  # Can move if "acceptItem" is true
	return false  # Can't move if no tile data
