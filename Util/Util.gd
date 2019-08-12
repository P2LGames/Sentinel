extends Node

func get_file_name(filePath: String):
	var splitPath = filePath.split("/")
	
	if splitPath[splitPath.size() - 1] == "" and splitPath.size() > 1:
		return splitPath[splitPath.size() - 2]
	else:
		return splitPath[splitPath.size() - 1]

func slice_array(array, start: int = 0, stop: int = -1):
	
	var newArray = []
	
	# Get the end
	var end = array.size()
	
	# If stop was given a value, set it to be the end
	if stop != -1: 
		end = stop
	
	for i in range(start, end):
#		print(array[i])
		newArray.append(array[i])
	
	return newArray


func bytes2int(bytes: PoolByteArray) -> int:
	# Construct the integer byte header
	var intHeader: PoolByteArray = [2, 0, 0, 0]
	
	# Use bytes2var to create the integer we want
	var toReturn: int = bytes2var(intHeader + bytes)
	
	return toReturn


func int2bytes(integer: int) -> PoolByteArray:
	# Get the bytes of the int, but trim off the ends, since it's 8 bytes
	var dataLength = var2bytes(integer)
	
	# Remove the first 4 bytes, they are padding
	for x in range(4):
		dataLength.remove(0)
	
	# Invert the data to be BIG_ENDIAN for java to understand
	dataLength.invert()
	
	return dataLength


func float2bytes(f: float) -> PoolByteArray:
	# Get the bytes of the int, but trim off the ends, since it's 8 bytes
	var dataLength = var2bytes(f)
	
	# Remove the first 4 bytes, they are padding
	for x in range(4):
		dataLength.remove(0)
	
	# Invert the data to be BIG_ENDIAN for java to understand
	dataLength.invert()
	
	return dataLength


func bytes2float(bytes: PoolByteArray) -> float:
	# Construct the integer byte header
	var floatHeader: PoolByteArray = [3, 0, 0, 0]
	
	# Use bytes2var to create the integer we want
	var toReturn: float = bytes2var(floatHeader + bytes)
	
	return toReturn


func bytes2string(bytes: PoolByteArray) -> String:
	var stringHeader: PoolByteArray = [4, 0, 0, 0]
	
	return bytes2var(stringHeader + bytes)


func padWithBytes(bytes: PoolByteArray, padding: int) -> PoolByteArray:
	var paddedBytes := bytes
	for i in range(padding):
		paddedBytes.append(0)
	
	return paddedBytes


func draw_empty_circle(node: Node2D, center: Vector2, radius: Vector2, color: Color, resolution: int):
	var draw_counter = 1
	var line_origin = Vector2()
	var line_end = Vector2()
	line_origin = radius + center

	while draw_counter <= 360:
		line_end = radius.rotated(deg2rad(draw_counter)) + center
		node.draw_line(line_origin, line_end, color)
		draw_counter += 1 / resolution
		line_origin = line_end

	line_end = radius.rotated(deg2rad(360)) + center
	node.draw_line(line_origin, line_end, color)

func draw_circle_arc(node: Node2D, center: Vector2, radius: Vector2, angle_from: float, angle_to: float, color: Color):
    var nb_points = 32
    var points_arc = PoolVector2Array()

    for i in range(nb_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
        points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

    for index_point in range(nb_points):
        node.draw_line(points_arc[index_point], points_arc[index_point + 1], color)