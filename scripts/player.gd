extends CharacterBody2D

const SPEED = 100.0
const DASH_SPEED = 650.0
var DASHING = false
	
func _physics_process(delta: float) -> void:
	get_input(delta)

	# Add the gravity.
	if !is_on_floor() and !DASHING:
		velocity.y += get_gravity().y * delta

	if (!DASHING):
		velocity.x = move_toward(velocity.x, 0, 20) # Also would affect the speed of acceleration

	move_and_slide()

func _on_direction_dash_timer_timeout():
	DASHING = false
		
func get_input(delta : float) -> void:
	# Ground movement
	if (is_on_floor()):
		if Input.is_action_pressed("key_right"): 
			velocity.x = SPEED
		if Input.is_action_pressed("key_left"): 
			velocity.x = -SPEED
		if Input.is_action_just_pressed("key_up"): 
			velocity.y -= DASH_SPEED/2
			$DirectionDashTimer.start()
			DASHING = true
		
	# Small dash
	elif (!DASHING and !is_on_floor()):
		var small_dash_dir = Vector2.ZERO
		if Input.is_action_just_pressed("key_up"): small_dash_dir.y = -1
		if Input.is_action_just_pressed("key_down"): small_dash_dir.y = 1
		if Input.is_action_just_pressed("key_right"): small_dash_dir.x = 1
		if Input.is_action_just_pressed("key_left"): small_dash_dir.x = -1
		
		if (small_dash_dir != Vector2.ZERO):
			velocity = small_dash_dir * DASH_SPEED/2
			$DirectionDashTimer.start()
			DASHING = true
			
	# Mouse Dash
	var mouse_pos = get_viewport().get_mouse_position()
	var player_pos = get_global_transform_with_canvas().get_origin() + Vector2($Sprite2D.texture.get_width()/2, $Sprite2D.texture.get_height()/2)
	if Input.is_action_just_pressed("mouse_left"): 
		velocity = (mouse_pos - player_pos).normalized() * DASH_SPEED
		
	# Cancel all movement with space
	if Input.is_action_just_pressed("key_space"):
		velocity = Vector2.ZERO	
	
