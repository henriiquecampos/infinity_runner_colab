extends Position2D

export (PackedScene) var objectScene
onready var objectPath = objectScene.get_path()
onready var object = load(objectPath)
onready var mainNode = get_parent()

onready var timer = get_node("timer")
func _ready():
	timer.start()

func _on_timer_timeout():
	randomize()
	var newObjectInstance = object.instance()
	mainNode.add_child(newObjectInstance)
	newObjectInstance.set_pos(get_pos())