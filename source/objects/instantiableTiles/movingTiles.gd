extends KinematicBody2D

var movingSpeed = globals.movingObjectsSpeed

func _on_visibilityNotifier_exit_screen():
	queue_free()

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if is_colliding():
		if get_collision_normal().x != 0 and get_collider() != null:
			get_collider().queue_free()
	move(Vector2(-1, 0) * movingSpeed * delta)