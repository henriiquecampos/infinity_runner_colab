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
var alreadyJumped = false

#Slide related variables
var alreadySlided = false
#Player StateMachine
export (String, "RUNNING", "JUMPING", "SLIDING", "HOOKING") var playerCurrentState

#Collision handling variables
var collider
onready var shape = get_node("shape").get_shape()
onready var originalShapeSize = shape.get_radius()

#Variables needed to maintain the player on the same screen position when running
onready var originalPos = get_pos()
func _ready():
	print(playerCurrentState)
	set_fixed_process(true)

func _fixed_process(delta):
	
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
			#makes the character always move towards the fixed screen position where it started
			if (get_global_pos() - get_node("../screenPos").get_global_pos()).x > 20:
				move_local_x(-globals.movingObjectsSpeed * delta)
			if (get_global_pos() - get_node("../screenPos").get_global_pos()).x < 20:
				move_local_x(globals.movingObjectsSpeed * delta)
			canJump = true
		if get_collision_normal().y > 0:
			canJump = false

func jump(delta):
	#Makes sure that the player cant jump if it is sliding
	if playerCurrentState != "SLIDING":
		if Input.is_action_pressed("jump") and canJump and not alreadyJumped:
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
			playerCurrentState = "JUMPING"
		else:
			playerCurrentState ="RUNNING"
		alreadyJumped = Input.is_action_pressed("jump")

func slide(delta):
	#This function halves the player collision shape so that it can pass below some obstacles
	#Of course the player can only slide on the ground
	#and not jumping
	if is_colliding():
		if playerCurrentState != "JUMPING" and collider != null and collider.is_in_group("platform"):
			#The player has full control on how much he/she will be sliding, so it can stop
			#sliding anytime, but the slide has a fixed duration (default 1sec)
			if Input.is_action_pressed("slide") and not alreadySlided:
				#takes the collision shape and halves it chaning the player state to slide
				#also starts the sliding duration timer
				shape.set_radius(shape.get_radius() / 2)
				get_node("sprite").set_scale(Vector2(1, 0.5))
				playerCurrentState = "SLIDING"
				get_node("timer").start()
			elif not Input.is_action_pressed("slide") and alreadySlided:
				#toggles the player state to default with the default shape size and
				#default state, also stops the timer so that it doesn't reset it again
				playerCurrentState = "RUNNING"
				shape.set_radius(originalShapeSize)
				get_node("sprite").set_scale(Vector2(1, 1))
				get_node("timer").stop()
			elif Input.is_action_pressed("slide") and playerCurrentState == "SLIDING":
				#applies a increased movement speed to give the player the feel that the
				#character is actually sliding
				move(Vector2(globals.movingObjectsSpeed, 0) * 2 * delta)
	alreadySlided = Input.is_action_pressed("slide")

func _on_timer_timeout():
	#This makes sure the player can't slide
	#through the whole game
	playerCurrentState = "RUNNING"
	get_node("sprite").set_scale(Vector2(1, 1))
	shape.set_radius(originalShapeSize)

func _on_visibilityNotifier_exit_screen():
	get_tree().quit()
