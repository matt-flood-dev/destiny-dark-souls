class_name MagazineState
extends RefCounted

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---

var configuration: WeaponDefinitions.Configuration = WeaponDefinitions.Configuration.PISTOL_SIDEARM
var mag_capacity: int = 12
var max_magazine_count: int = 0
var capacity_upgrade_level: int = 0
var gun_mag_index: int = 0
var round_counts: Array[int] = []


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func setup_initial(data: WeaponData) -> void:
	configuration = data.configuration
	mag_capacity = data.base_mag_capacity
	max_magazine_count = data.max_magazine_count
	capacity_upgrade_level = 0
	gun_mag_index = 0
	round_counts.clear()

	for i in range(data.starting_magazine_count):
		if i == 0:
			round_counts.append(data.base_mag_capacity)
		else:
			round_counts.append(0)


func get_gun_rounds() -> int:
	if round_counts.is_empty():
		return 0

	return round_counts[gun_mag_index]


func get_gun_capacity() -> int:
	return mag_capacity


func get_total_rounds() -> int:
	var total: int = 0

	for round_count in round_counts:
		total += round_count

	return total


func has_any_ammo() -> bool:
	return get_total_rounds() > 0


func has_ammo_in_gun() -> bool:
	return get_gun_rounds() > 0


func consume_round() -> void:
	if get_gun_rounds() <= 0:
		return

	round_counts[gun_mag_index] -= 1


func can_reload() -> bool:
	return find_reload_mag_index() >= 0


func perform_reload_swap() -> bool:
	var new_index: int = find_reload_mag_index()
	if new_index < 0:
		return false

	gun_mag_index = new_index
	return true


func can_add_magazine_slot() -> bool:
	if max_magazine_count <= 0:
		return false

	return round_counts.size() < max_magazine_count


func add_magazine_slot() -> bool:
	if not can_add_magazine_slot():
		return false

	round_counts.append(0)
	return true


func get_magazine_count() -> int:
	return round_counts.size()


func get_magazine_rounds(magazine_index: int) -> int:
	if magazine_index < 0 or magazine_index >= round_counts.size():
		return 0

	return round_counts[magazine_index]


func get_missing_rounds(magazine_index: int) -> int:
	if magazine_index < 0 or magazine_index >= round_counts.size():
		return 0

	return mag_capacity - round_counts[magazine_index]


func add_rounds(magazine_index: int, rounds: int) -> int:
	if rounds <= 0 or magazine_index < 0 or magazine_index >= round_counts.size():
		return 0

	var rounds_to_add: int = mini(rounds, get_missing_rounds(magazine_index))
	round_counts[magazine_index] += rounds_to_add
	return rounds_to_add


func set_mag_capacity(new_capacity: int) -> void:
	mag_capacity = new_capacity

	for i in range(round_counts.size()):
		round_counts[i] = mini(round_counts[i], mag_capacity)


# --- PRIVATE METHODS ---

func find_reload_mag_index() -> int:
	for i in range(round_counts.size()):
		if i == gun_mag_index:
			continue

		if round_counts[i] > 0:
			return i

	return -1
