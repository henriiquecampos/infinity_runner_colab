extends RayCast2D

export (NodePath) var parentPath
onready var parentNode = get_node(parentPath)

func _ready():
	set_process(true)
	
func _process(delta):
	set_cast_to(Vector2(0, 1) * 1000)
	get_node("sprite").set_global_pos(Vector2(parentNode.get_global_pos().x, get_collision_point().y))
