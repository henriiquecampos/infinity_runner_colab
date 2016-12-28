extends RayCast2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process(true)
	
func _process(delta):
	set_cast_to(Vector2(0, -1) * 1000)
	if is_colliding():
		get_node("sprite").set_pos(get_collision_point())
