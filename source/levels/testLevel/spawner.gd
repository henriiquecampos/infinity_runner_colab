extends Position2D

export (PackedScene) var objectScene
onready var objectPath = objectScene.get_path()
onready var object = load(objectPath)
onready var mainNode = get_parent()

var lastObject
onready var timer = get_node("timer")
func _ready():
	randomize()
	timer.start()

func _on_timer_timeout():
	var newObjectInstance = object.instance()
	mainNode.add_child(newObjectInstance)
	newObjectInstance.set_pos(get_pos())
	lastObject = newObjectInstance
	lastObject.get_node("visibilityNotifier").connect("enter_screen", self, "resetSpawn")
	timer.set_wait_time(rand_range(0.2,2.0))
	
func resetSpawn():
	timer.start()