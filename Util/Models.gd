extends Node

func Order(type: int, parameter: PoolByteArray):
	var order = {
		type = type,
		parameter = parameter
	}
	
	return order