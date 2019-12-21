extends KinematicBody

# Player movement speed
var speed = 700
var sprintSpeedMultiplier = 1.4

func _physics_process(delta):
	# Get player input
	var direction: Vector3
	var cameraAim = $Head/Camera.get_global_transform().basis
	
	if Input.is_action_pressed("ui_down"):
		direction += Vector3(cameraAim.z[0], 0,  cameraAim.z[2])
	if Input.is_action_pressed("ui_up"):
		direction -= Vector3(cameraAim.z[0], 0,  cameraAim.z[2])
	if Input.is_action_pressed("ui_left"):
		direction -= Vector3(cameraAim.x[0], 0,  cameraAim.x[2])
	if Input.is_action_pressed("ui_right"):
		direction += Vector3(cameraAim.x[0], 0,  cameraAim.x[2])
	if Input.is_action_pressed("fly_up"):
		direction += Vector3(0,1,0)
	if Input.is_action_pressed("fly_down"):
		direction -= Vector3(0,1,0)
		
	
	
	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	# Apply movement
	var movement = speed * direction * delta
	
	if Input.is_action_pressed("sprint"):
		movement*=sprintSpeedMultiplier
	move_and_collide(movement)