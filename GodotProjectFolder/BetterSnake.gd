extends Node3D


var time = 0
var sensitivity = 0.1
var distance = 5
var other_dist = 1

var marker_array = [[],[]]


# Called when the node enters the scene tree for the first time.
func _ready():
	
	marker_array[0].insert(0, global_position)
	marker_array[1].insert(0, global_rotation)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	var dist_to_last_log = global_position.distance_to(marker_array[0][0])
	if dist_to_last_log > 20 * delta:
		#print(dist_to_last_log)
		marker_array[0].push_front(global_position)
		marker_array[1].push_front(global_rotation)
	
	#distance /= (marker_array[0][0].distance_to(marker_array[0][1]))
	
	for i in range(get_child_count()):
		var current_child = get_child(i)
		var prev_child = get_child(i-1)
		if i == 0:
			prev_child = self
		
		if marker_array[0].size() > distance * i:
			current_child.global_position = current_child.global_position.lerp(marker_array[0][distance * i], 0.25)
			
			var angle = prev_child.global_position.direction_to(current_child.global_position)
			if angle.angle_to(prev_child.global_transform.basis.z) > PI/8:
				angle = (prev_child.global_transform.basis.z + prev_child.global_transform.basis.z.direction_to(angle) * PI/8).normalized()
			current_child.global_position = current_child.global_position.lerp(prev_child.global_position + angle * other_dist, 0.4)
			
			current_child.look_at(prev_child.global_position, Vector3.UP)
			current_child.rotation.x = 0
			current_child.rotation.z = 0
	
	#time += 1 * delta
	#global_position.y += sin(time * 5) * 0.025
#	position.x += sin(time * 20) * 0.015
	
	while marker_array[0].size() > get_child_count() * distance:
		marker_array[0].pop_back()
		marker_array[1].pop_back()
	
# move thru the queue faster if youre moving faster!!
