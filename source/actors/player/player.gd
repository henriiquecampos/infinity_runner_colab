extends KinematicBody2D

#Player's physics
const GRAVITY = 800
export var playerJumpForce = 1800

#export var playerVelocity = 100
#I commented player's horizontal movement until I define if the best way is to move the player
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

#Variables needed to maintain the player on the same screen position when running
onready var originalPos = get_pos()
func _ready():
	print(playerStates)
	set_fixed_process(true)

func _fixed_process(delta):
	#just to debug the current state of the player, I need to remeber to erase it
	for state in playerStates:
		if playerStates[state] == playerCurrentState:
			get_node("state").set_text(str(state))
	
	#call the needed functions to have basic movements and mechanics
	checkCollisions(delta)
	applyCustomForces(delta)
	jump(delta)
	slide(delta)

func applyCustomForces(delta):
	#Ok, this is dumb, but I created a custom function to apply this single
	#custom force, but who knows, maybe we add new forces in the future
	move(Vector2(0,1) * GRAVITY * delta)

func checkCollisions(delta):
	#verifies collisiong to enable the jump mechanic and stores the last collider to future usage
	if is_colliding():
		collider = get_collider()
		if collider.is_in_group("platform"):
			if (get_global_pos() - get_node("../screenPos").get_global_pos()).x > 20:
				move_local_x(-globals.movingObjectsSpeed * delta)
			if (get_global_pos() - get_node("../screenPos").get_global_pos()).x < 20:
				move_local_x(globals.movingObjectsSpeed * delta)
			canJump = true
		if get_collision_normal().y > 0:
			canJump = false

func jump(delta):
	#Makes sure that the player cant jump if it is sliding
	if playerCurrentState != playerStates.SLIDING:
		if Input.is_action_just_pressed("jump") and canJump:
			#This stores the position from where the player first jumped and disable multiple jumps
			lastPos = get_pos()
			currentPos = get_pos()
			canJump = false
		#This verification takes the position where the jump started, so the player
		#alwyas have a limited max height, but #not a minimum. This is what I should
		#have done in MoonCheeser to give a better jump control to the player
		if Input.is_action_pressed("jump") and lastPos.distance_to(currentPos) < jumpHeight and canJump:
			currentPos = get_pos()
			move(Vector2(0, -1) * playerJumpForce * delta)
			#changes the player state to be jumping just for future verifications using
			#the state machine
			playerCurrentState = playerStates.JUMPING
		else:
			playerCurrentState = playerStates.RUNNING

func slide(delta):
	#This function halves the player collision shape so that it can pass below some obstacles
	#Of course the player can only slide on the ground
	#and not jumping
	if is_colliding():
		if playerCurrentState != playerStates.JUMPING and collider != null and collider.is_in_group("platform"):
			#The player has full control on how much he/she will be sliding, so it can stop
			#sliding anytime, but the slide has a fixed duration (default 1sec)
			if Input.is_action_just_pressed("slide"):
				#takes the collision shape and halves it chaning the player state to slide
				#also starts the sliding duration timer
				shape.set_extents(Vector2(shape.get_extents().x, shape.get_extents().y / 2))
				playerCurrentState = playerStates.SLIDING
				get_node("timer").start()
			elif Input.is_action_just_released("slide"):
				#toggles the player state to default with the default shape size and
				#default state, also stops the timer so that it doesn't reset it again
				playerCurrentState = playerStates.RUNNING
				shape.set_extents(originalShapeSize)
				get_node("timer").stop()
			elif Input.is_action_pressed("slide") and playerCurrentState == playerStates.SLIDING:
				#applies a increased movement speed to give the player the feel that the
				#character is actually sliding
				move(Vector2(globals.movingObjectsSpeed, 0) * 2 * delta)

func _on_timer_timeout():
	#This makes sure the player can't slide
	#through the whole game
	playerCurrentState = playerStates.RUNNING
	shape.set_extents(originalShapeSize)