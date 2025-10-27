class_name GeneticAlgorithm
extends Node

var best_height := INF
var best_permutation := []

var population_size := 50
var generations := 100
var mutation_rate := 0.1
var elitism := 2

var max_no_improve := 20

func calculate_best_height() -> void:
	generations = int(sqrt(GlobalData.number_of_blocks))
	best_height = INF
	best_permutation.clear()

	var animations_bool = GlobalData.animations_bool
	GlobalData.animations_bool = false

	var original_blocks = GlobalData.blocks.duplicate(true)
	var block_ids := {}
	for block in original_blocks:
		block_ids[block.id] = block

	var original_ids := []
	for block in original_blocks:
		original_ids.append(block.id)

	print("Genetic algorithm begun!")

	var population = []
	for i in range(population_size):
		
		var shuffled = [] + original_ids
		shuffled.shuffle()
		population.append(shuffled)

	var fitness_cache := {}

	var last_best_height := INF
	var no_improve := 0

	for gen in range(generations):
		var scored_population = []

		for perm in population:
			var key = str(perm)
			var height: float

			if fitness_cache.has(key):
				height = fitness_cache[key]
			else:
				var new_order := []
				for id in perm:
					new_order.append(block_ids[id])
				GlobalData.blocks = new_order

				height = get_parent().calculate_height()
				fitness_cache[key] = height

			scored_population.append({"perm": perm, "height": height})

			if height < best_height:
				best_height = height
				best_permutation = perm.duplicate()

		scored_population.sort_custom(func(a, b):
			return a["height"] < b["height"]
		)

		print("Generacija ", gen + 1, "/", generations, " najbolja visina: ", scored_population[0]["height"])

		if best_height < last_best_height:
			last_best_height = best_height
			no_improve = 0
		else:
			no_improve += 1

		if no_improve >= max_no_improve:
			print("Nema poboljšanja već ", max_no_improve, " generacija, prekidamo ranije")
			break

		var new_population = []

		for i in range(min(elitism, scored_population.size())):
			new_population.append(scored_population[i]["perm"])

		while new_population.size() < population_size:
			var parent1 = scored_population[randi() % (population_size / 2)]["perm"]
			var parent2 = scored_population[randi() % (population_size / 2)]["perm"]

			var child = crossover(parent1, parent2)
			if randf() < mutation_rate:
				mutate(child)
			new_population.append(child)

		population = new_population

	print("Best height: ", best_height)
	print("Best block permutation: ", best_permutation)

	var new_order := []
	for id in best_permutation:
		new_order.append(block_ids[id])
	GlobalData.blocks = new_order

	GlobalData.animations_bool = animations_bool


func crossover(parent1: Array, parent2: Array) -> Array:
	var start = randi() % parent1.size()
	var end = randi() % parent1.size()
	if start > end:
		var tmp = start
		start = end
		end = tmp

	var child = []
	child.resize(parent1.size())

	for i in range(start, end + 1):
		child[i] = parent1[i]

	var p2_index = 0
	for i in range(parent1.size()):
		if child[i] == null:
			while parent2[p2_index] in child:
				p2_index += 1
			child[i] = parent2[p2_index]
	return child


func mutate(perm: Array) -> void:
	var i = randi() % perm.size()
	var j = randi() % perm.size()
	var tmp = perm[i]
	perm[i] = perm[j]
	perm[j] = tmp
