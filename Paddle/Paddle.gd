extends KinematicBody2D

var velocity = Vector2.ZERO
onready var y_location = global_position.y
var touch_position = Vector2.ZERO

enum {
	MOUSE,
	TOUCH
}

var input_type = MOUSE

func _physics_process(_delta):
	var target = Vector2.ZERO
	if input_type == MOUSE:
		target = Vector2(
			get_global_mouse_position().x - global_position.x, 0
		)
	else:
		target = touch_position
# warning-ignore:return_value_discarded
	move_and_collide(target)
	global_position.y = y_location


func _input(event):
	if input_type == TOUCH and event is InputEvent.SCREEN_TOUCH:
		input_type = TOUCH
		touch_position = event.position
