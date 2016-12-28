extends RemoteTransform2D

#export (NodePath) var hookPath
#onready var hookNode = get_node(hookPath)
#
#func _ready():
#	set_process(true)
#	
#func _process(delta):
#	var distanceToReference = get_global_pos().distance_to(hookNode.get_global_pos())
#	get_node("rope").set_region_rect(Rect2(0, 0, distanceToReference, 12))
#	get_node("rope").set_rot( -deg2rad(90) + get_angle_to(Vector2(hookNode.get_global_pos())))