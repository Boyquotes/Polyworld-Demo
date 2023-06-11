extends Node3D


var target : Node3D
var skeleton_ik : SkeletonIK3D
var time := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	target = $Armature/Skeleton3D/Target
	skeleton_ik = $Armature/Skeleton3D/SkeletonIK3D
	skeleton_ik.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += 0.1
	position.z += 0.1
	target.position.y = sin(time) * 1
	
