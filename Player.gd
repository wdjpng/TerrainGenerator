extends KinematicBody

# Player movement speed
export var speed = 400

func _physics_process(delta):
	# Get player input
	var direction: Vector2
	
	direction.x =  Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	# Apply movement
	var movement = speed * direction * delta
	
	if Input.is_action_pressed("shift"):
		movement*=2
	move_and_collide(Vector3(direction.x, 0, direction.y))