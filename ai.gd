extends Node

func distance_comparitor(node, lval, rval):
	var ldist = lval.position.distance_to(node.position)
	var rdist = rval.position.distance_to(node.position)
	return ldist < rdist

func _constrained_point(subject, target, current_rotation, max_turn, position):
	var ideal_face = fmod(subject.get_angle_to(target.position) + PI / 2, PI * 2) # TODO: Global Position?
	var ideal_turn = fmod(ideal_face - current_rotation, PI * 2)
	if(ideal_turn > PI):
		ideal_turn = fmod(ideal_turn - 2 * PI, 2 * PI)

	elif(ideal_turn < -1 * PI):
		ideal_turn = fmod(ideal_turn + 2 * PI, 2 * PI)
	
	max_turn = sign(ideal_turn) * max_turn  # Ideal turn in the right direction
	
	if(abs(ideal_turn) > abs(max_turn)):
		return [max_turn, ideal_face]
	else:
		return [ideal_turn, ideal_face]
