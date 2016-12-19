extends Position2D

export (PackedScene) var objectScene
onready var objectPath = objectScene.get_path()
var object = load(objectPath)