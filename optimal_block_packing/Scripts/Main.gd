extends Node

@onready var container = $SubViewportContainer/SubViewport/Container
@onready var control_panel = $ControlPanel
@onready var block_storage = $BlockStorage

func _ready() -> void:
	control_panel.draw_container_signal.connect(container.draw_container)
	control_panel.calculate_best_height.connect(container.calculate_best_height)
	control_panel.show_blocks_in_storage.connect(block_storage.show_blocks)
	control_panel.show_blocks_in_storage.connect(hide_label)
	control_panel.hide_label.connect(hide_label)
	control_panel.show_blocks_in_storage.connect(container.remove_blocks_from_container)
	control_panel.switch_to_2d_view.connect(container.setup_2d_view)
	control_panel.switch_to_3d_view.connect(container.setup_3d_view)
	control_panel.maybe_show_blocks_in_storage.connect(block_storage.maybe_show_blocks)
	container.highlight_this_block_in_storage.connect(block_storage.highlight_next_block)
	container.show_blocks_in_storage.connect(block_storage.show_blocks)
	container.calculation_finished.connect(update_label)
	
func update_label() -> void:
	$Label.text = "Best height: " + String.num(GlobalData.package_height, 3)
	$Label.show()
	
func hide_label() -> void:
	$Label.hide()
	$Label.text = "Best height: 0"
