extends Node2D

@export var itemcontainer : Node2D

func _on_timer_timeout():
	var item = load("res://scenes/item.tscn")
	var newitem = item.instantiate()
	itemcontainer.add_child(newitem)
	
