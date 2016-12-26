extends KinematicBody2D

#General Hook speed
export (int) var hookShotSpeed
export (int) var hookShotRecoilSpeed
var mousePos

#Variables needed to make the hook
#goes back when not fired
export (NodePath) var gunReferencePath
onready var gunReference = get_node(gunReferencePath)
var canRecoil = true

#Player node References
export (NodePath) var playerPath
onready var playerNode = get_node(playerPath)

var isColliding = false
var collider
var collisionPos
func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	shotTheGun(delta)
	recoilTheGun(delta)
	
func shotTheGun(delta):
	#Triggers the recoil function
	#and erase the remote transformer
	#reference to itself, so it recoils
	#smoothly
	if Input.is_action_just_released("shotHookGun"):
		canRecoil = true
	if Input.is_action_just_pressed("shotHookGun"):
		gunReference.set_remote_node("")
		mousePos = get_viewport().get_mouse_pos()
	#Activates the hook, making it go towards
	#the mouse position, stoping if it is out
	#of the hookgun's range
	if Input.is_action_pressed("shotHookGun") and not canRecoil:
		if get_global_pos().distance_to(gunReference.get_global_pos()) < gunReference.get_child(0).hookRange:
			#if it is not colliding it moves until it reach
			#something and then pulls the player
			#toward the hook position
			if isColliding:
				playerNode.move(Vector2(0,1).rotated(playerNode.get_angle_to(self.get_global_pos())) * hookShotRecoilSpeed * delta)
				
			if mousePos != null and get_global_pos().distance_to(mousePos) > 20 and not isColliding:
				move(Vector2(0,1).rotated(get_angle_to(get_viewport().get_mouse_pos())) * hookShotSpeed * delta)
			elif not isColliding and get_global_pos().distance_to(mousePos) < 20:
				canRecoil = true
		elif get_global_pos().distance_to(gunReference.get_global_pos()) > gunReference.get_child(0).hookRange:
			canRecoil = true
func recoilTheGun(delta):
	#Verifies the distance to where the gun
	#should stay while idle. It also sets the
	#remote transformer to reference itself
	#so that it keep following the player 
	#when it is not being shot
	if canRecoil and get_global_pos().distance_to(gunReference.get_global_pos()) > 10:
		move((gunReference.get_global_pos() - self.get_global_pos()).normalized() * hookShotRecoilSpeed * delta)
	if get_global_pos().distance_to(gunReference.get_global_pos()) < 10:
		gunReference.set_remote_node(get_path())
		canRecoil = false

func _on_area_body_enter( body ):
	isColliding = true
	collider = body
	collisionPos = get_global_pos()
	if body.get_name() == "player":
		canRecoil = true

func _on_area_body_exit( body ):
	isColliding = false

func _on_area_area_enter( area ):
	isColliding = true
	collider = area
	collisionPos = get_global_pos()

func _on_area_area_exit( area ):
	isColliding = false
