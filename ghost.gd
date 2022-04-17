extends KinematicBody2D

const MOTION_SPEED = 160 # Pixels/second.
enum States { STOPPED, MOVING }
var _state = States.STOPPED
var _destination = Vector2()
var _next_cell = position
var _path = []

func _physics_process(_delta):
	if _state == States.MOVING:
		if position.distance_to(_next_cell) < 2:
			position = _next_cell
			if not _path or len(_path) == 1:
				_state = States.STOPPED
			else:
				_next_cell = _path.pop_at(1)
		else:
			var motion = Vector2(_next_cell.x - position.x, _next_cell.y - position.y)
			move_and_slide(motion.normalized() * MOTION_SPEED)

func _unhandled_input(event):
	if event.is_action_pressed("click"):
		_destination = get_global_mouse_position()
		_path = get_node("../../TileMap2").get_astar_path(position, _destination)		
		_state = States.MOVING
