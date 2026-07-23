@tool
extends Line2D

var wall_elements: Dictionary

func load_wall_scenes() -> void:
	var directory = DirAccess.open("res://Scenes/SplineWall/Bricks/")
	
	if !directory:
		printerr("Given path does not exist")
		return
		
	directory.list_dir_begin()
	
	var file_name = directory.get_next()
	
	while file_name != "":
		wall_elements[int(file_name.left(-5))] = directory.get_current_dir() + "/" + file_name
		file_name = directory.get_next()

func _ready() -> void:
	await load_wall_scenes()
	
	for wall_point in len(points):
		
		var new_wall_element = load(wall_elements[180]).instantiate()
		new_wall_element.global_position = points[wall_point]
		add_child(new_wall_element) 
		
		
		
