extends KinematicBody2D

var starting_velocity = 700;
var starting_angle = 35;
var velocity = Vector2.ZERO
onready var starting_position = global_position
onready var respawnTimer = $RespawnTimer
onready var soundPlayer = $SoundAnimationPlayer
onready var paddle = get_tree().current_scene.get_node("YSort/Paddle")
var min_angle = 80
var UP_ANGLE = rad2deg(Vector2.UP.angle())

enum {
	WAIT,
	MOVE,
}

var state = WAIT

func _ready():
	velocity = starting_velocity

func _physics_process(delta):
	if state == WAIT:
		wait(delta)
	else:
		move(delta)

func wait(_delta):
	var paddle_position = paddle.global_position
	global_position = Vector2(paddle_position.x, paddle_position.y - 20)

func _input(event):
	if event.is_action_released("StartBall") or event is InputEventScreenTouch:
		if not event.pressed:
			velocity = Vector2.UP.rotated(deg2rad(starting_angle)) * starting_velocity
			state = MOVE

func move(delta):
	var original_velocity = velocity
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.normal)
		if collision_info.collider.collision_layer == 8:
			collide_with_paddle(collision_info)
		elif collision_info.collider.collision_layer == 4:
			collide_with_block(original_velocity, collision_info)
		else:
			soundPlayer.play("Bounce")
		prevent_horizontal()

func prevent_horizontal():
	if abs(velocity.y) < 50:
		velocity.y += 50 * sign(velocity.y)

func collide_with_paddle(collision_info):
	var sprite = collision_info.collider.get_node("Sprite")
	var width = sprite.texture.get_size()[0] * sprite.scale.x
	var distance = global_position.x - collision_info.collider.global_position.x
	var angle_weight = inverse_lerp(-width/2, width/2, distance)
	var rotate = lerp(-75, 75, angle_weight)
	velocity = velocity.rotated(deg2rad(rotate))
	var new_angle = rad2deg(velocity.angle())
	if new_angle < UP_ANGLE - min_angle:
		velocity = velocity.rotated(deg2rad(new_angle - new_angle + min_angle))
	elif new_angle > UP_ANGLE + min_angle:
		velocity = velocity.rotated(deg2rad(new_angle - new_angle - min_angle))
	soundPlayer.play("Paddle")

func collide_with_block(original_velocity, collision_info):
	var tile_pos = collision_info.collider.world_to_map(
		collision_info.position + original_velocity.normalized()
	)
	collision_info.collider.set_cell(tile_pos[0], tile_pos[1], -1)
	soundPlayer.play("Break")

func _on_Area2D_area_entered(area):
	if area.collision_layer == 16:
		velocity = Vector2.ZERO
		global_position = Vector2(-100, -100)
		respawnTimer.start(1.5)


func _on_RespawnTimer_timeout():
	state = WAIT
