extends Node

class_name Order
func Order(type: int, parameter: PoolByteArray):
	var order = {
		type = type,
		parameter = parameter
	}
	
	return order

func PrintMessage(message: String, type: int):
	var mess = {
		message = message,
		type = type
	}
	
	return mess
