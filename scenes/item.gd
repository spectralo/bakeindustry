extends Node2D
class_name Item

@export_category("Item Settings")
@export var ItemTexture: Texture
@export var Type: String = "simple_item"
@export var Name: String

var velocity: Vector2 = Vector2.ZERO
var target_velocity: Vector2 = Vector2.ZERO
@export var acceleration: float = 20.0
@export var speed_multiplier: float = 4.0

func _process(delta: float) -> void:
	var tilemap = get_parent()
	if tilemap:
		var tile_pos: Vector2i = tilemap.local_to_map(position)
		var tiledata = tilemap.get_cell_tile_data(tile_pos)
		if tiledata:
			var new_vector = tiledata.get_custom_data("vector")
			if new_vector:
				target_velocity = new_vector * speed_multiplier
			else:
				target_velocity = Vector2.ZERO
		else:
			target_velocity = Vector2.ZERO
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	position += velocity * delta
