extends MarginContainer

@export var texture : String = ""
@export var focus_texture : String = ""
@export var item_name : String = ""

signal pressed

func _on_tree_entered() -> void:
	$decorationbtn.texture_normal = load("res://assets/decorations-ind/"+texture)
	$decorationbtn.texture_hover = load("res://assets/decorations-ind/"+focus_texture)


func _on_decorationbtn_pressed() -> void:
	emit_signal("pressed")
