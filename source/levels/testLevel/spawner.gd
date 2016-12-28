extends Position2D

#Reference variables to the object(s) that
#will be spawned
export (PackedScene) var objectScene
onready var objectPath = objectScene.get_path()
onready var object = load(objectPath)
onready var mainNode = get_parent()
#variables needed to reset the timer
#the condition is to only respawn
#after the object is being fully
#shown to the player

var lastObject

#variables needed to control the
#time between instances
export (float) var minSpawnTime
export (float) var maxSpawnTime
onready var timer = get_node("timer")

func _ready():
	#actually starts the timer with a the
	#first spawn being fixed so the player
	#have a reaction time to know what
	#will happen in the game
	randomize()
	timer.start()

func _on_timer_timeout():
	print(get_name())
	#creates a new instance of the reference
	#object and add it to the scene
	#setting the postion to be the position
	#where the spawn was when the object
	#spawned
	var newObjectInstance = object.instance()
	mainNode.add_child(newObjectInstance)
	newObjectInstance.set_pos(get_pos())
	#connects the last instance signal
	#to the function below, making it
	#check if it can restart the timer
	lastObject = newObjectInstance
	#lastObject.get_node("visibilityNotifier").connect("enter_viewport", self, "resetSpawn")
	resetSpawn()
	#randomize a new wait time so that
	#we have random positions to spawn
	#the instanciated object
	timer.set_wait_time(rand_range(minSpawnTime,maxSpawnTime)/globals.dificultyMultiplier)
	get_node("animator").set_speed(globals.dificultyMultiplier)
	
func resetSpawn():
	timer.start()