extends CharacterBody2D

@export var tilemap: TileMapLayer
@export var goal: Vector2i
@export var speed: int = 100
@export var acceleration: float = 5.0

var goal_pos: Vector2
var direction: String = ""
var movement_disabled: bool = false
var is_blocked_left: bool = false
var is_blocked_right: bool = false
var is_blocked_top: bool = false
var is_blocked_bottom: bool = false

func _ready() -> void:
	if tilemap == null:
		tilemap = get_tree().get_first_node_in_group("movement") as TileMapLayer
	direction = get_direction()
	set_goal(direction)

func check_movement() -> void:
	movement_disabled = (direction == "bottom" and is_blocked_bottom) or \
						(direction == "up" and is_blocked_top) or \
						(direction == "left" and is_blocked_left) or \
						(direction == "right" and is_blocked_right)

func _physics_process(delta: float) -> void:
	direction = get_direction()
	check_movement()
	goal_pos = tilemap.to_global(tilemap.map_to_local(goal))
	
	if goal_pos.distance_to(position) < 10.0:
		set_goal(direction)
		goal_pos = tilemap.to_global(tilemap.map_to_local(goal))
	
	var dir_vector: Vector2 = (goal_pos - position).normalized()
	var target_velocity: Vector2 = dir_vector * speed
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	
	if not movement_disabled:
		move_and_collide(velocity * delta)

func get_direction() -> String:
	var cell_pos: Vector2i = tilemap.local_to_map(tilemap.to_local(position))
	var data: TileData = tilemap.get_cell_tile_data(cell_pos)
	if data:
		return data.get_custom_data("direction") as String
	return "null"

func set_goal(dir_str: String) -> void:
	var cell_pos: Vector2i = tilemap.local_to_map(tilemap.to_local(position))
	var new_goal: Vector2i = cell_pos
	
	match dir_str:
		"bottom": new_goal = Vector2i(cell_pos.x, cell_pos.y + 1)
		"up": new_goal = Vector2i(cell_pos.x, cell_pos.y - 1)
		"left": new_goal = Vector2i(cell_pos.x - 1, cell_pos.y)
		"right": new_goal = Vector2i(cell_pos.x + 1, cell_pos.y)
		_: new_goal = cell_pos
	
	var data: TileData = tilemap.get_cell_tile_data(new_goal)
	if data and data.get_custom_data("acceptItem"):
		goal = new_goal
	else:
		goal = cell_pos

func _on_top_body_entered(body: Node2D) -> void:
	is_blocked_top = true

func _on_top_body_exited(body: Node2D) -> void:
	is_blocked_top = false

func _on_right_body_entered(body: Node2D) -> void:
	is_blocked_right = true

func _on_right_body_exited(body: Node2D) -> void:
	is_blocked_right = false

func _on_bottom_body_entered(body: Node2D) -> void:
	is_blocked_bottom = true

func _on_bottom_body_exited(body: Node2D) -> void:
	is_blocked_bottom = false

func _on_left_body_entered(body: Node2D) -> void:
	is_blocked_left = true

func _on_left_body_exited(body: Node2D) -> void:
	is_blocked_left = false
