extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var tilemap : TileMapLayer
@export var goal : Vector2i
@export var goal_pos : Vector2
@export var speed = 100
@export var acceleration: float = 5.0
@export var direction :String

var leftno : bool
var rightno : bool
var topno : bool
var bottomno : bool
var movementdisabled : bool

func _ready():
	tilemap = get_tree().get_first_node_in_group("movement")
	set_goal(get_direction())

func check_movement():
	match direction:
		"bottom":
			if bottomno:
				movementdisabled = true
			else:
				movementdisabled = false
		"up":
			if topno:
				movementdisabled = true
			else:
				movementdisabled = false
		"left":
			if leftno:
				movementdisabled = true
			else:
				movementdisabled = false
		"right":
			if rightno:
				movementdisabled = true
			else:
				movementdisabled = false


func _physics_process(delta):
	get_direction()
	check_movement()
	goal_pos = tilemap.to_global(tilemap.map_to_local(goal))
	if goal_pos.distance_to(position) < 10:
		set_goal(get_direction())
	var direction = (goal_pos - position).normalized()
	var target_velocity = direction * speed
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	if !movementdisabled:
		move_and_collide(velocity*delta)

func get_direction():
	var directionrn : String = "null"
	var cell_pos : Vector2i = (tilemap.local_to_map(tilemap.to_local(position)))
	var data : TileData = tilemap.get_cell_tile_data(cell_pos)
	if data:
		directionrn = data.get_custom_data("direction")
	direction = directionrn
	return directionrn

func set_goal(direction:String):
	var cell_pos = (tilemap.local_to_map(tilemap.to_local(position)))
	var newgoal : Vector2i
	match direction:
		"bottom": newgoal = Vector2i(cell_pos.x,cell_pos.y+1)
		"up": newgoal = Vector2i(cell_pos.x,cell_pos.y-1)
		"left": newgoal = Vector2i(cell_pos.x-1,cell_pos.y)
		"right": newgoal = Vector2i(cell_pos.x+1,cell_pos.y)
		_: newgoal = cell_pos
		
	var data = tilemap.get_cell_tile_data(newgoal)
	if data:
		var acceptItem = data.get_custom_data("acceptItem")
		if acceptItem:
			goal = newgoal
		else:
			goal = cell_pos
	else:
		goal = cell_pos


func _on_top_body_entered(body):
	topno = true


func _on_top_body_exited(body):
	topno = false


func _on_right_body_entered(body):
	rightno = true

func _on_right_body_exited(body):
	rightno = false

func _on_bottom_body_entered(body):
	bottomno = true

func _on_bottom_body_exited(body):
	bottomno = false

func _on_left_body_entered(body):
	leftno = true

func _on_left_body_exited(body):
	leftno = false
