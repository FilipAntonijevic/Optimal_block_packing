class_name Block_storage extends Control

@onready var three_blocks_place = preload("res://Scenes/three_block_places.tscn")

var block_number : int = 1
@onready var warning_label = $warning_label
func show_blocks() -> void:
	for child in $ScrollContainer/VBoxContainer.get_children():
		child.queue_free()
	if GlobalData.render_visual_storage:
		warning_label.hide()
			
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
	else:
		warning_label.show()
func highlight_next_block() -> void:
	if GlobalData.render_visual_storage:
		var row_index = int((block_number - 1) / 3)
		var col_index = int((block_number - 1) % 3) + 1 

		var row = $ScrollContainer/VBoxContainer.get_child(row_index)
		if row == null:
			return
		
		var block_node = row.get("block_%d" % col_index)
		if block_node != null:
			block_node.highlight()
		
		block_number += 1
		if block_number - 1 == GlobalData.blocks.size():
			block_number = 1
