class_name BonfireRespawn
extends RefCounted

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

const GROUP_NAME: String = "bonfire_respawn"


# --- DATA & REFERENCES ---


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

static func respawn_all(scene_tree: SceneTree) -> void:
	for node in scene_tree.get_nodes_in_group(GROUP_NAME):
		if node.has_method("respawn"):
			node.call("respawn")


# --- PRIVATE METHODS ---
