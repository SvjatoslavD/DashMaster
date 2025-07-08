class_name Player
extends CharacterBody2D

const accel = 800 # currently unused as velocity is set to target within one frame
const decel = 400
const max_speed = 2600
# dir_dash is the keyboard dash; long_dash is the mouse dash
const dir_dash_speed_mult = 2.5
const long_dash_speed_mult = 5

var key_press_input = Vector2.ZERO
var key_held_input = Vector2.ZERO
var mouse_press_input = Vector2.ZERO
# only one type of dash can be active at a time
var dir_dashing := false
var long_dashing := false
var dir_dash_cd := false
var running := false

@onready var player_animation := $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	player_movement(delta)
	apply_physics(delta)
	move_and_slide()

func player_movement(delta: float) -> void:
	get_key_press_input()
	get_key_held_input()
	get_mouse_press_input()
	
	# handles dashes
	if (mouse_press_input != Vector2.ZERO and !long_dashing and !dir_dashing):
		long_dashing = true
		$LongDashTimer.start()
		handle_dashing(delta)
		player_animation.play("Dashing")

	elif (key_press_input != Vector2.ZERO and !dir_dashing and !long_dashing and !dir_dash_cd):
		dir_dashing = true
		$DirDashTimer.start()
		handle_dashing(delta)
		player_animation.play("Dashing")
		
	# handles walking
	if (running and !long_dashing and !dir_dashing):
		if (key_held_input.x == 0): running = false
		else: 
			velocity.x = key_held_input.x * max_speed * delta
			player_animation.play("Running")
		
	if (velocity.x > 0): player_animation.flip_h = false
	elif (velocity.x < 0): player_animation.flip_h = true
	
	if (velocity == Vector2.ZERO and is_on_floor()):
		player_animation.play("Idle")
	

func apply_physics(delta: float) -> void:
	if (key_press_input == Vector2.ZERO and !dir_dashing and !long_dashing):
		# set gravity to 500px/s from 980px/s
		velocity += get_gravity() * delta
		velocity.x = move_toward(velocity.x, 0, decel * delta)

func get_key_press_input() -> void:
	key_press_input.x = int(Input.is_action_just_pressed("key_right")) - int(Input.is_action_just_pressed("key_left"))
	key_press_input.y = int(Input.is_action_just_pressed("key_down")) - int(Input.is_action_just_pressed("key_up"))
	if (key_press_input != Vector2.ZERO): key_press_input.normalized()

func get_key_held_input() -> void:
	key_held_input.x = int(Input.is_action_pressed("key_right")) - int(Input.is_action_pressed("key_left"))
	key_held_input.y = int(Input.is_action_pressed("key_down")) - int(Input.is_action_pressed("key_up"))
	if (key_held_input != Vector2.ZERO): key_held_input.normalized()

func get_mouse_press_input() -> void:
	if Input.is_action_just_pressed("mouse_left"):
		var mouse_pos = get_viewport().get_mouse_position()
		var player_pos = get_global_transform_with_canvas().get_origin() + Vector2(5, 6)
		mouse_press_input = mouse_pos - player_pos # if you normalize the value here, you can't use it to determine long_dash speed

func handle_dashing(delta: float) -> void:
	if (dir_dashing):
		# the dir_dash timer handles the duration 
		# speed change should be gradual
		velocity = (key_held_input * max_speed * dir_dash_speed_mult * delta)
	elif (long_dashing):
		# the long_dash only has a duration handled by the long_dash timer
		# roughly a length of 300 from player to top/ bottom of screen, and a length of roughly 500 from either side of the screen
		# speed is determined by the mouse distance from player
		velocity = mouse_press_input.normalized() * (max_speed * long_dash_speed_mult * (clamp(mouse_press_input.length(), 50, 200)/200) * delta) 

func _on_dir_dash_timer_timeout() -> void:
	dir_dashing = false
	dir_dash_cd = true
	$DirDashCdTimer.start()
	if (key_held_input.x != 0):
		running = true

func _on_long_dash_timer_timeout() -> void:
	long_dashing = false
	mouse_press_input = Vector2.ZERO

func _on_dir_dash_cd_timer_timeout() -> void:
	dir_dash_cd = false
