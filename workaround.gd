extends VoxelInstancer


var ids = {}


func _ready() -> void:
	# HACK: after upgrading godot_voxel it seems like the min/max height of
	# various things is messed up. I can't find a fix for this, nor can I
	# reproduce it outside of this map. But it seems to be fixed by setting the
	# min/max height again after a delay
	for id in library.get_all_item_ids():
		var item = library.get_item(id)
		var minh = item.generator.min_height
		var maxh = item.generator.max_height
		ids[id] = [minh, maxh]
		#Logger.info("%s min_height=%f, max_height=%f" % [item.name, minh, maxh])
		item.generator.min_height = 0
		item.generator.max_height = 0


func _on_timer_timeout() -> void:
	for id in library.get_all_item_ids():
		var item = library.get_item(id)
		var stored_item = ids[id]
		item.generator.min_height = stored_item[0]
		item.generator.max_height = stored_item[1]
