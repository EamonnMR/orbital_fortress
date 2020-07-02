extends Node

func distance_comparitor(node, lval, rval):
	var ldist = lval.position.distance_to(node.position)
	var rdist = rval.position.distance_to(node.position)
	return ldist < rdist

