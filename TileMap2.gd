extends TileMap

# You can only create an AStar node from code, not from the Scene tab.
onready var astar_node = AStar.new()

func _ready():
	var walkable_tiles = get_used_cells_by_id(0)
	_astar_add_walkable_cells(walkable_tiles)
	_astar_connect_walkable_cells(walkable_tiles)

func _astar_add_walkable_cells(walkable_tiles: Array):
	for walkable_tile in walkable_tiles:
		var walkable_tile_index = _calculate_point_index(walkable_tile)
		
		astar_node.add_point(
			walkable_tile_index,
			Vector3(walkable_tile.x, walkable_tile.y, 0.0)
		)

func _astar_connect_walkable_cells(walkable_tiles: Array):
	for walkable_tile in walkable_tiles:
		var point_index = _calculate_point_index(walkable_tile)
		var points_relative = PoolVector2Array([
			walkable_tile + Vector2.RIGHT,
			walkable_tile + Vector2.LEFT,
			walkable_tile + Vector2.DOWN,
			walkable_tile + Vector2.UP,
		])
		for point_relative in points_relative:
			var point_relative_index = _calculate_point_index(point_relative)
			if get_cellv(point_relative) == INVALID_CELL:
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			astar_node.connect_points(point_index, point_relative_index, false)

func get_astar_path(world_path_start: Vector2, world_path_end: Vector2):
	var map_path_start = world_to_map(world_path_start)
	var map_path_end = world_to_map(world_path_end)
	
	var point_path =_get_point_path(map_path_start, map_path_end)
	
	var path_world = []
	for point in point_path:
		var point_world = map_to_world(Vector2(point.x, point.y))
		path_world.append(
			Vector2(
				point_world.x,
				point_world.y + cell_size.y / 2
			)
		)
		
	return path_world

func _get_point_path(map_start_position: Vector2, map_end_position: Vector2):
	var start_point_index = _calculate_point_index(map_start_position)
	var end_point_index = _calculate_point_index(map_end_position)
	
	var astar_node_path = astar_node.get_point_path(start_point_index, end_point_index)
	
	return astar_node_path
	
func _calculate_point_index(map_point: Vector2):
	var x_positive = "0"
	if map_point.x >= 0:
		x_positive = "1"
		
	var y_positive = "0"
	if map_point.y >= 0:
		y_positive = "1"
		
	var point_index = "1" + String(abs(map_point.x)) + x_positive + y_positive + String(abs(map_point.y))
	
	return point_index.to_int()
