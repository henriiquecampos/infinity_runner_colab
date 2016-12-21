extends KinematicBody2D

#Player's physics
const GRAVITY = 600
export var playerJumpForce = 1800

#export var playerVelocity = 100
#I commented player's horizontal movement until 
#I define if the best way is to move the player
#or the instantiated objects

#Jump variables needed for limit the jump height
export var jumpHeight = 200
var lastPos
var currentPos
var canJump = true

#Player StateMachine
enum playerStates{RUNNING, JUMPING, SLIDING, HOOKING}
onready var playerCurrentState = playerStates.RUNNING

#Collision handling variables
var collider
onready var shape = get_node("shape").get_shape()
onready var originalShapeSize = shape.get_extents()
func _ready():
	print(playerStates)
	set_fixed_process(true)

func _fixed_process(delta):
	for state in playerStates:
		if playerStates[state] == playerCurrentState:
			get_node("state").set_text(str(state))
	checkCollisions()
	applyCustomForces(delta)
	jump(delta)
	slide()

func applyCustomForces(delta):
	move(Vector2(0,1) * GRAVITY * delta)

func checkCollisions():
	if is_colliding():
		collider = get_collider()
		if collider.is_in_group("platform"):
			canJump = true
		if get_collision_normal().y > 0:
			canJump = false

func jump(delta):
	if playerCurrentState != playerStates.SLIDING:
		if Input.is_action_just_pressed("ui_accept") and canJump:
			lastPos = get_pos()
			currentPos = get_pos()
			canJump = false
		if Input.is_action_pressed("ui_accept") and lastPos.distance_to(currentPos) < jumpHeight and canJump:
			currentPos = get_pos()
			move(Vector2(0, -1) * playerJumpForce * delta)
			playerCurrentState = playerStates.JUMPING
		else:
			playerCurrentState = playerStates.RUNNING

func slide():
	if playerCurrentState != playerStates.JUMPING:
		if Input.is_action_just_pressed("ui_down"):
			shape.set_extents(Vector2(shape.get_extents().x, shape.get_extents().y / 2))
			playerCurrentState = playerStates.SLIDING
			get_node("timer").start()
		elif Input.is_action_just_released("ui_down"):
			playerCurrentState = playerStates.RUNNING
			shape.set_extents(originalShapeSize)
			get_node("timer").stop()

func _on_timer_timeout():
	playerCurrentState = playerStates.RUNNING
	shape.set_extents(originalShapeSize)