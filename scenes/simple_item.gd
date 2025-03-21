extends Node2D

var tilemap : TileMapLayer
var current_dir : String = "up"
var goal_pos : Vector2
var can_move : bool = true
var tolerance := 0.1
var speed := 200
var is_blocked = true

var allowed_tiles = [
	Vector2i(0,0),
	Vector2i(0,2),
	Vector2i(0,4),
	Vector2i(0,6),
	Vector2i(0,8),
	Vector2i(0,10),
	Vector2i(0,12),
	Vector2i(0,14),
	Vector2i(0,16),
	Vector2i(0,18),
	Vector2i(0,20),
	Vector2i(0,22),
	Vector2i(6,0),
	Vector2i(6,2),
	Vector2i(6,4),
	Vector2i(6,6)
]

@export var up : RayCast2D
@export var bottom : RayCast2D
@export var left : RayCast2D
@export var right : RayCast2D

var directions := {
	"left": Vector2i(-1, 0),
	"right": Vector2i(1, 0),
	"up": Vector2i(0, -1),
	"bottom": Vector2i(0, 1),
	"": Vector2i(0, 0)
}

func _ready():
	$checktimer.start()
	tilemap = get_tree().get_first_node_in_group("movement")
	current_dir = check_direction()
	set_goal()

func check_direction() -> String:
	var cell = tilemap.local_to_map(tilemap.to_local(position))
	var data = tilemap.get_cell_tile_data(cell)
	if data:
		return data.get_custom_data("direction")
	return ""

func set_goal():
	current_dir = check_direction()
	var cell = tilemap.local_to_map(tilemap.to_local(position))
	var newcell = cell + directions[current_dir]
	goal_pos = tilemap.to_global(tilemap.map_to_local(newcell))
	print("new set goalled",newcell)

func _process(delta):
	if check_next_tile():
		set_goal()
	obstruing_check()
	if goal_pos:
		var distance = goal_pos - position
		if distance.length() < tolerance:
			check_next_tile()
			set_goal()
		if can_move and not is_blocked:
			var direction = distance.normalized()
			position += direction * speed * delta

func obstruing_check():
	match current_dir:
		"up":
			is_blocked = up.is_colliding()
		"bottom":
			is_blocked = bottom.is_colliding()
		"left":
			is_blocked = left.is_colliding()
		"right":
			is_blocked = right.is_colliding()

func check_next_tile():
	current_dir = check_direction()
	var nextcell = tilemap.local_to_map(tilemap.to_local(position))+directions[current_dir]
	if tilemap.get_cell_atlas_coords(nextcell) in allowed_tiles:
		can_move = true
		return true
	else:
		var distance = goal_pos - position
		if distance.length() < tolerance:
			can_move = false
			return false
