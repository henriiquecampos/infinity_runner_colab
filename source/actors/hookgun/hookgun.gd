extends KinematicBody2D

export (int) var hookShotSpeed
export (int) var hookShotRecoilSpeed

export (NodePath) var gunReferencePath
onready var gunReference = get_node(gunReferencePath)

var canRecoil
func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	if Input.is_action_just_pressed("ui_up"):
		get_tree().set_pause(true)
	shotTheGun(delta)
	if canRecoil and get_global_pos().distance_to(gunReference.get_global_pos()) > 10:
		move((gunReference.get_global_pos() - self.get_global_pos()).normalized() * hookShotRecoilSpeed * delta)
	if get_global_pos().distance_to(gunReference.get_global_pos()) < 10:
		canRecoil = false

func shotTheGun(delta):
	if Input.is_action_pressed("shotHookGun") and not is_colliding() and not canRecoil:
		move(Vector2(0,1).rotated(get_angle_to(get_viewport().get_mouse_pos())) * hookShotSpeed * delta)
	if Input.is_action_just_released("shotHookGun"):
		canRecoil = true
