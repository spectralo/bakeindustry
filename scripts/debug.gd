extends Node 

@export var debug_key_action_name : String = "debug"

var debug_lines_visible : bool = false

func _ready():
	# Initialization code if needed
	pass

func _process(delta):
	if Input.is_action_just_pressed(debug_key_action_name):
		toggle_debug_lines()

func toggle_debug_lines():
	debug_lines_visible = not debug_lines_visible

	if debug_lines_visible:
		add_debug_lines_to_path2ds()
	else:
		remove_debug_lines_from_path2ds()

func add_debug_lines_to_path2ds():
	var path2ds = get_tree().get_nodes_in_group("movement")
	for path2d in path2ds:
		if path2d is Path2D: # Ensure it's actually a Path2D node
			add_line_to_path2d(path2d)

func remove_debug_lines_from_path2ds():
	var path2ds = get_tree().get_nodes_in_group("movement")
	for path2d in path2ds:
		if path2d is Path2D: # Ensure it's actually a Path2D node
			remove_line_from_path2d(path2d)

func add_line_to_path2d(path_node : Path2D):
	var line2d = Line2D.new()
	line2d.name = "DebugLine2D" # Give it a name to easily find and remove later
	line2d.width = 10 # Adjust line width as needed
	line2d.default_color = Color.LIME_GREEN # Red color for debug line, change as desired

	# Get points from the Path2D's curve
	var points = path_node.curve.get_baked_points()
	line2d.points = points
	path_node.add_child(line2d)

func remove_line_from_path2d(path_node : Path2D):
	var debug_line = path_node.get_node("DebugLine2D")
	if debug_line:
		debug_line.queue_free() #  queue_free() safely deletes the node in the next frame
