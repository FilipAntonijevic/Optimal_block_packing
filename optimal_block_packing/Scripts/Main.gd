extends Node

@onready var container = $SubViewportContainer/SubViewport/Container
@onready var control_panel = $ControlPanel
@onready var block_storage = $BlockStorage

func _ready() -> void:
	control_panel.draw_container_signal.connect(container.draw_container)
	control_panel.add_blocks_signal.connect(container.add_blocks)
	control_panel.show_blocks_in_storage.connect(block_storage.show_blocks)
	control_panel.switch_to_2d_view.connect(container.setup_2d_view)
	control_panel.switch_to_3d_view.connect(container.setup_3d_view)
	container.highlight_this_block_in_storage.connect(block_storage.highlight_next_block)
