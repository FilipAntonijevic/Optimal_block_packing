class_name Block_storage extends Control

@onready var three_blocks_place = preload("res://Scenes/three_block_places.tscn")

func show_blocks() -> void:
	for child in $ScrollContainer/VBoxContainer.get_children():
		child.queue_free()
		
	var blocks = GlobalData.blocks
	var rows = int(ceil(float(blocks.size()) / 3.0))
	var block_index = 0

	for i in range(rows):
		var row_instance = three_blocks_place.instantiate()
		$ScrollContainer/VBoxContainer.add_child(row_instance)

		for j in range(3):
			if block_index < blocks.size():
				var block_data = blocks[block_index]
				var block_node = row_instance.get("block_%d" % (j+1))
				block_node.setup_block_preview(block_data.id, block_data.width, block_data.depth, block_data.height)
				block_index += 1
			else:
				row_instance.get("block_%d" % (j+1)).label.visible = false
				row_instance.get("block_%d" % (j+1)).polygon.visible = false
