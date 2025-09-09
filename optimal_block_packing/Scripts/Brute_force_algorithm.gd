class_name BruteForce extends Node

var best_height = INF
var best_permutation = []

func calculate_best_height() -> void:
	# reset
	best_height = INF
	best_permutation.clear()

	var animations_bool = GlobalData.animations_bool
	GlobalData.animations_bool = false

	# svaki put pravi svež snapshot blokova
	var original_blocks = GlobalData.blocks.duplicate(true) # deep copy
	var block_ids := {}
	for block in original_blocks:
		block_ids[block.id] = block

	var original_ids := []
	for block in original_blocks:
		original_ids.append(block.id)

	print("Počinjem testiranje permutacija...")
	test_permutations(original_ids, block_ids)

	print("Brute force završen!")
	print("Najbolja visina: ", best_height)
	print("Najbolja permutacija: ", best_permutation)

	var new_order := []
	for id in best_permutation:
		new_order.append(block_ids[id])
	GlobalData.blocks = new_order.duplicate()

	GlobalData.animations_bool = animations_bool
	
func test_permutations(ids: Array, block_ids: Dictionary) -> void:
	var all_perms = permutations(ids) 
	for i in range(all_perms.size()):
		var perm = all_perms[i]
		var new_order := []
		for id in perm:
			new_order.append(block_ids[id])
		GlobalData.blocks = new_order.duplicate()
		
		var height = get_parent().calculate_height()
		
		#print("Permutacija ", i+1, "/", all_perms.size(), ": visina = ", height)

		if height < best_height:
			best_height = height
			best_permutation.clear()
			best_permutation.append_array(perm)
	print(best_permutation)
	print('Height' + str(best_height))

func permutations(arr: Array) -> Array:
	if arr.size() <= 1:
		return [arr]
	var result = []
	for i in range(arr.size()):
		var rest = arr.duplicate()
		var current = rest[i]
		rest.remove_at(i)
		for perm in permutations(rest):
			result.append([current] + perm)
	return result
