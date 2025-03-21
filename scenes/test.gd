extends Node2D

var test_node = preload("res://scenes/simple_item.tscn")  # Replace with your actual node scene
var node_count := 0
var found_threshold := false

func _process(delta):
	if found_threshold:
		return
	
	await get_tree().create_timer(2).timeout 
	
	# Measure FPS
	var fps = Engine.get_frames_per_second()

	# Add new nodes until FPS < 60
	if fps >= 60:
		var new_node = test_node.instantiate()
		add_child(new_node)
		node_count += 1
	else:
		found_threshold = true
		OS.alert("FPS dropped below 20 with "+str(node_count)+" nodes.")
		queue_free()
		print("FPS dropped below 20 with", node_count, "nodes.")
