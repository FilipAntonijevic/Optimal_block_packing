extends Node


@export var container_width : float = 1
@export var container_depth : float = 1

@export var block_min_width : float = 0.1
@export var block_max_width : float = 1
@export var block_min_depth : float = 0.1
@export var block_max_depth : float = 1
@export var block_min_height : float = 0.1
@export var block_max_height : float = 5

@export var number_of_blocks : int = 1

func _ready() -> void:
	pass 


func _on_container_width_line_edit_text_submitted(new_text: String) -> void:
	if new_text.to_float() < 1:
		container_width = 1
		$Container_width_line_edit.text = str(container_width)
	else:
		container_width = new_text.to_float()
	$Block_max_width_line_edit.text = str(container_width)
	block_max_width = container_width
	if $Block_min_width_line_edit.text.to_float() > container_width:
		block_min_width = container_width
		$Block_min_width_line_edit.text = str(block_min_width)
		
func _on_container_depth_line_edit_text_submitted(new_text: String) -> void:
	if new_text.to_float() < 1:
		container_depth = 1
		$Container_depth_line_edit.text = str(container_depth)
	else:
		container_depth = new_text.to_float()
	$Block_max_depth_line_edit.text = str(container_depth)
	block_max_depth = container_depth
	if $Block_max_depth_line_edit.text.to_float() > container_depth:
		block_min_depth = container_depth
		$Block_max_depth_line_edit.text = str(block_min_depth)

func _on_block_min_width_line_edit_text_submitted(new_text: String) -> void:
	var parsed = new_text.to_float()
	if parsed > container_width:
		parsed = container_width
	if parsed < 0.01:
		parsed = 0.01
	if parsed > block_max_width:
		parsed = block_max_width
	block_min_width = parsed
	$Block_min_width_line_edit.text = str(parsed)

func _on_block_max_width_line_edit_text_submitted(new_text: String) -> void:
	var parsed = new_text.to_float()
	if parsed > container_width:
		parsed = container_width
	if parsed < 0.01:
		parsed = 0.01
	if parsed < block_min_width:
		parsed = block_min_width
	block_max_width = parsed
	$Block_max_width_line_edit.text = str(parsed)

func _on_block_min_depth_line_edit_text_submitted(new_text: String) -> void:
	var parsed = new_text.to_float()
	if parsed > container_depth:
		parsed = container_depth
	if parsed < 0.01:
		parsed = 0.01
	if parsed > block_max_depth:
		parsed = block_max_depth
	block_min_depth = parsed
	$Block_min_depth_line_edit.text = str(parsed)

func _on_block_max_depth_line_edit_text_submitted(new_text: String) -> void:
	var parsed = new_text.to_float()
	if parsed > container_depth:
		parsed = container_depth
	if parsed < 0.01:
		parsed = 0.01
	if parsed < block_min_depth:
		parsed = block_min_depth
	block_max_depth = parsed
	$Block_max_depth_line_edit.text = str(parsed)

func _on_block_min_height_line_edit_text_submitted(new_text: String) -> void:
	var parsed : float = new_text.to_float()
	if parsed > block_max_height:
		parsed = block_max_height
	if parsed < 0.01:
		parsed = 0.01
	block_min_height = parsed
	$Block_min_height_line_edit.text = str(block_min_height)

func _on_block_max_height_line_edit_text_submitted(new_text: String) -> void:
	var parsed : float = new_text.to_float()
	if parsed < block_min_height:
		parsed = block_min_height
	block_max_height = parsed
	$Block_max_height_line_edit.text = str(block_max_height)

func _on_number_of_blocks_line_edit_text_submitted(new_text: String) -> void:
	var parsed = int(new_text) if new_text.is_valid_int() else 1
	if parsed < 1:
		parsed = 1
	number_of_blocks = parsed
	$Number_of_blocks_line_edit.text = str(number_of_blocks)
