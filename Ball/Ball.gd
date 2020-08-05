extends KinematicBody2D

var starting_velocity = Vector2(-150, -700);
var velocity = Vector2.ZERO
onready var starting_position = global_position
onready var respawnTimer = $RespawnTimer
onready var soundPlayer = $SoundAnimationPlayer
var min_angle = 80
var UP_ANGLE = rad2deg(Vector2.UP.angle())

func _ready():
	velocity = starting_velocity

func _physics_process(delta):
	var original_velocity = velocity
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		soundPlayer.play("Bounce")
		velocity = velocity.bounce(collision_info.normal)
		if collision_info.collider.collision_layer == 8:
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
		elif collision_info.collider.collision_layer == 4:
			var tile_pos = collision_info.collider.world_to_map(
				collision_info.position + original_velocity.normalized()
			)
			collision_info.collider.set_cell(tile_pos[0], tile_pos[1], -1)
			soundPlayer.play("Break")
		if abs(velocity.y) < 50:
			velocity.y += 50 * sign(velocity.y)

func _on_Area2D_area_entered(area):
	if area.collision_layer == 16:
		velocity = Vector2.ZERO
		global_position = Vector2(-100, -100)
		respawnTimer.start(1.5)


func _on_RespawnTimer_timeout():
	velocity = self.starting_velocity
	global_position = self.starting_position
