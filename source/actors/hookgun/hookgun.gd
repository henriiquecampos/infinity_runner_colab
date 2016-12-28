extends KinematicBody2D

#General Hook speed
export (int) var hookShotSpeed
export (int) var hookShotRecoilSpeed
var shotAngle

#Variables needed to make the hook goes back when not fired
export (NodePath) var gunReferencePath
onready var gunReference = get_node(gunReferencePath)
var canRecoil = true
var alreadyShoot = false

#Player node References
export (NodePath) var playerPath
onready var playerNode = get_node(playerPath)

#Variables needed for collisiong handling
var isColliding = false
var collider
var collisionPos
func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	shotTheGun(delta)
	recoilTheGun(delta)
	
func shotTheGun(delta):
	var distanceToReference = get_global_pos().distance_to(gunReference.get_global_pos())
	get_node("rope").set_region_rect(Rect2(0, 0, distanceToReference, 12))
	get_node("rope").set_rot( -deg2rad(90) + get_angle_to(Vector2(gunReference.get_global_pos())))
	#Triggers the recoil function and erase the remote transformer reference to itself, so it recoils smoothly
	if not Input.is_action_pressed("shotHookGun") and alreadyShoot:
		canRecoil = true
	if Input.is_action_pressed("shotHookGun") and not alreadyShoot:
		gunReference.set_remote_node("")
		shotAngle = gunReference.get_child(0).get_cast_to().normalized()
		set_rot(get_angle_to(shotAngle))
		get_node("sprite").set_flip_h(true)
	#Activates the hook, making it go towards the mouse position, stoping if it is out of the hookgun's range
	if Input.is_action_pressed("shotHookGun"):
		if not canRecoil:
			if get_global_pos().distance_to(gunReference.get_global_pos()) < gunReference.get_child(0).hookRange:
				#if it is not colliding it moves until it reach something and then pulls the player
				#toward the hook position
				if not isColliding:
					move(shotAngle * hookShotSpeed * delta)
				if isColliding:
					if collider.is_in_group("ground"):
						canRecoil = true
					playerNode.playerCurrentState = "HOOKING"
					playerNode.move(Vector2(0,1).rotated(playerNode.get_angle_to(self.get_global_pos())) * hookShotRecoilSpeed * delta)
					move(Vector2(-globals.movingObjectsSpeed,0) * delta)
					playerNode.move(Vector2(-globals.movingObjectsSpeed,0) * delta)
				elif get_global_pos().distance_to(gunReference.get_global_pos()) > gunReference.get_child(0).hookRange:
					canRecoil = true
	#Sets the boolean that will enable the behaviour of "Input.is_action_just_pressed"
	alreadyShoot = Input.is_action_pressed("shotHookGun")
func recoilTheGun(delta):
	#Verifies the distance to where the gun should stay while idle. It also sets the remote 
	#transformer to reference itself so that it keep following the player when it is not being shot
	if canRecoil and get_global_pos().distance_to(gunReference.get_global_pos()) > 15:
		move((gunReference.get_global_pos() - self.get_global_pos()).normalized() * hookShotRecoilSpeed * delta)
	elif get_global_pos().distance_to(gunReference.get_global_pos()) < 15:
		gunReference.set_remote_node(get_path())
		canRecoil = false
		get_node("sprite").set_flip_h(false)

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
