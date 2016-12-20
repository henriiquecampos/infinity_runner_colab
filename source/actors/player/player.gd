extends KinematicBody2D

#Player's physics
const GRAVITY = 700

#commented player's horizontal movement until 
#I define if the best way is to move the player
#or the instantiated objects

#export var playerVelocity = 100
export var playerJumpForce = 1800
#Jump variables needed for limit the jump height
export var jumpHeight = 100
var lastPos
var currentPos
var canJump = true
#Collision handling variables
var collider
func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	applyCustomForces(delta)
	checkCollisions()
	print(is_colliding())
	jump()
	
func jump():
	if Input.is_action_just_pressed("ui_accept") and canJump:
		lastPos = get_pos()
		currentPos = get_pos()
		canJump = false
	if Input.is_action_pressed("ui_accept") and lastPos.distance_to(currentPos) < jumpHeight:
		currentPos = get_pos()
		move_and_slide(Vector2(0, -playerJumpForce))
	if Input.is_action_just_released("ui_accept"):
		pass
		
func applyCustomForces(delta):
	move(Vector2(0,1) * GRAVITY * delta)
	
	#this is preventing any collision check, need to report the bug
	#move_and_slide(Vector2(playerVelocity, 0))
	
func checkCollisions():
	if is_colliding():
		collider = get_collider()
		print(collider.get_name())
		if collider.is_in_group("platform"):
			canJump = true