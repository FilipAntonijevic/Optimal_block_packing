extends Node

@export var container_width : float = 1
@export var container_depth : float = 1

@export var block_min_width : float = 0.1
@export var block_max_width : float = 1
@export var block_min_depth : float = 0.1
@export var block_max_depth : float = 1
@export var block_min_height : float = 0.1
@export var block_max_height : float = 1

@export var number_of_blocks : int = 10

@onready var controls = [
		$Label3,
		$Label2,
		$Label5,
		$Label6,
		$Label7,
		$Label8,
		$Label10,
		$Label11,
		$Number_of_blocks_line_edit,
		$Block_max_height_line_edit,
		$Block_min_height_line_edit,
		$Block_max_depth_line_edit,
		$Block_min_depth_line_edit,
		$Block_max_width_line_edit,
		$Block_min_width_line_edit,
		$Container_depth_line_edit,
		$Container_width_line_edit,

		$Generate_blocks_button,
		$Brute_force_algorithm_check_button,
		$Genetic_algorithm_check_button,
		
		$Calculate_best_block_order_button,
		$a_2D_button,
		$a_3D_button]
		
		
signal draw_container_signal()
signal calculate_best_height()
signal show_blocks_in_storage()
signal switch_to_2d_view()
signal switch_to_3d_view()
signal maybe_show_blocks_in_storage()

func _ready() -> void:
	$Container_width_line_edit.text = str(container_width)
	$Container_depth_line_edit.text = str(container_depth)
	$Block_min_width_line_edit.text = str(block_min_width)
	$Block_max_width_line_edit.text = str(block_max_width)
	$Block_min_depth_line_edit.text = str(block_min_depth)
	$Block_max_depth_line_edit.text = str(block_max_depth)
	$Block_min_height_line_edit.text = str(block_min_height)
	$Block_max_height_line_edit.text = str(block_max_height)
	$Number_of_blocks_line_edit.text = str(number_of_blocks)
	

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
	GlobalData.container_width = container_width
	GlobalData.max_block_width = block_max_width
	emit_signal("draw_container_signal")
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
	GlobalData.container_depth = container_depth
	GlobalData.max_block_depth = block_max_depth
	emit_signal("draw_container_signal")
	
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
	GlobalData.max_block_width = block_max_width
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
	GlobalData.max_block_depth = block_max_depth
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
	GlobalData.max_block_height = block_max_height
	$Block_max_height_line_edit.text = str(block_max_height)

func _on_number_of_blocks_line_edit_text_submitted(new_text: String) -> void:
	var parsed = int(new_text) if new_text.is_valid_int() else 1
	if parsed < 1:
		parsed = 1
	number_of_blocks = parsed
	$Number_of_blocks_line_edit.text = str(number_of_blocks)

func _on_generate_blocks_button_pressed() -> void:
	GlobalData.blocks.clear()
	collect_all_inputs()
	GlobalData.number_of_blocks = number_of_blocks
	for i in range(number_of_blocks):
		var block = Block.new()
		block.id = i + 1
		block.width = randf_range(block_min_width, block_max_width)
		block.depth = randf_range(block_min_depth, block_max_depth)
		block.height = randf_range(block_min_height, block_max_height)
		GlobalData.blocks.append(block)
	if GlobalData.blocks.size() > 2000:
		GlobalData.render_visual_storage = false
	else:
		GlobalData.render_visual_storage = true
	emit_signal("show_blocks_in_storage")

func _on_calculate_best_block_order_button_pressed() -> void:
	disable_all_buttons()
	await get_tree().process_frame 
	await get_tree().process_frame 
	emit_signal("calculate_best_height")
	await get_tree().process_frame 
	enable_all_buttons()
	
func disable_all_buttons() -> void:
	for c in controls:
		disable_ui(c)

func disable_ui(c: Control):
	if c.has_method("set_disabled"):
		c.disabled = true
	
	if c is LineEdit:
		c.editable = false
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	c.modulate = Color(0.6, 0.6, 0.6) 

func enable_all_buttons() -> void:
	for c in controls:
		enable_ui(c)

func enable_ui(c: Control):
	if c.has_method("set_disabled"):
		c.disabled = false
	
	if c is LineEdit:
		c.editable = true
		c.mouse_filter = Control.MOUSE_FILTER_STOP
	
	c.modulate = Color(1, 1, 1)


func _on_animation_check_button_toggled(toggled_on: bool) -> void:
	GlobalData.animations_bool = toggled_on

func collect_all_inputs() -> void:
	container_width = max(1.0, $Container_width_line_edit.text.to_float())
	container_depth = max(1.0, $Container_depth_line_edit.text.to_float())
	GlobalData.container_width = container_width
	GlobalData.container_depth = container_depth

	block_min_width = clamp($Block_min_width_line_edit.text.to_float(), 0.01, container_width)
	block_max_width = clamp($Block_max_width_line_edit.text.to_float(), block_min_width, container_width)
	block_min_depth = clamp($Block_min_depth_line_edit.text.to_float(), 0.01, container_depth)
	block_max_depth = clamp($Block_max_depth_line_edit.text.to_float(), block_min_depth, container_depth)
	block_min_height = clamp($Block_min_height_line_edit.text.to_float(), 0.01, block_max_height)
	block_max_height = max(block_min_height, $Block_max_height_line_edit.text.to_float())

	number_of_blocks = max(1, int($Number_of_blocks_line_edit.text.to_int()))

	GlobalData.min_block_width = block_min_width
	GlobalData.min_block_depth = block_min_depth
	GlobalData.max_block_width = block_max_width
	GlobalData.max_block_depth = block_max_depth
	GlobalData.max_block_height = block_max_height
	
	$Container_width_line_edit.text = str(container_width)
	$Container_depth_line_edit.text = str(container_depth)
	$Block_min_width_line_edit.text = str(block_min_width)
	$Block_max_width_line_edit.text = str(block_max_width)
	$Block_min_depth_line_edit.text = str(block_min_depth)
	$Block_max_depth_line_edit.text = str(block_max_depth)
	$Block_min_height_line_edit.text = str(block_min_height)
	$Block_max_height_line_edit.text = str(block_max_height)
	$Number_of_blocks_line_edit.text = str(number_of_blocks)

func _on_a_2d_button_pressed() -> void:
	GlobalData.view_2d = true
	GlobalData.min_block_depth = GlobalData.max_block_depth
	$Block_min_depth_line_edit.text = str(GlobalData.min_block_depth)
	disable_ui($Container_depth_line_edit)
	disable_ui($Label3)
	disable_ui($Label6)
	disable_ui($Block_max_depth_line_edit)
	disable_ui($Block_min_depth_line_edit)
	emit_signal("switch_to_2d_view")
	emit_signal("maybe_show_blocks_in_storage")

func _on_a_3d_button_pressed() -> void:
	GlobalData.view_2d = false
	enable_ui($Container_depth_line_edit)
	enable_ui($Label3)
	enable_ui($Label6)
	enable_ui($Block_max_depth_line_edit)
	enable_ui($Block_min_depth_line_edit)
	emit_signal("switch_to_3d_view")
	emit_signal("maybe_show_blocks_in_storage")


@onready var brute_btn: CheckButton = $Brute_force_algorithm_check_button
@onready var genetic_btn: CheckButton = $Genetic_algorithm_check_button

func _on_brute_force_algorithm_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		genetic_btn.button_pressed = false
		GlobalData.algorithm = "brute_force"
	else:
		if !genetic_btn.button_pressed:
			genetic_btn.button_pressed = true
			GlobalData.algorithm = "genetic_algorithm"

func _on_genetic_algorithm_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		brute_btn.button_pressed = false
		GlobalData.algorithm = "genetic_algorithm"
	else:
		if !brute_btn.button_pressed:
			brute_btn.button_pressed = true
			GlobalData.algorithm = "brute_force"
