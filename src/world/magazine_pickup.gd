extends Interactable
class_name MagazinePickup

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

@export var pickup_id: String = ""
@export var configuration: WeaponDefinitions.Configuration = WeaponDefinitions.Configuration.PISTOL_SIDEARM
@export var pickup_display_name: String = "Sidearm Magazine"


# --- DATA & REFERENCES ---


# --- LIFECYCLE CALLBACKS ---

func _ready() -> void:
	interaction_prompt = "Hold R to take " + pickup_display_name
	await get_tree().process_frame
	_apply_collected_state()


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

func can_interact(player: Player) -> bool:
	if not player:
		return false

	if pickup_id.is_empty():
		return false

	var loadout_manager: LoadoutManager = player.loadout_manager
	if loadout_manager.has_collected_magazine_pickup(pickup_id):
		return false

	if not loadout_manager.is_configuration_unlocked(configuration):
		return false

	return loadout_manager.can_add_magazine_slot(configuration)


func interact(player: Player) -> void:
	if not can_interact(player):
		return

	var loadout_manager: LoadoutManager = player.loadout_manager
	if not loadout_manager.try_add_magazine_slot(configuration):
		return

	loadout_manager.mark_magazine_pickup_collected(pickup_id)
	queue_free()


# --- PRIVATE METHODS ---

func _apply_collected_state() -> void:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		return

	if player.loadout_manager.has_collected_magazine_pickup(pickup_id):
		queue_free()
