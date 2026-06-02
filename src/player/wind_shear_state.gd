extends PlayerState

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---


# --- DATA & REFERENCES ---


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---

func _unhandled_input(_event: InputEvent) -> void:
	if not player:
		return


# --- UPDATE LOOPS ---

func update(delta: float) -> void:
	super(delta)
	if not player:
		return


func physics_update(_delta: float) -> void:
	if not player:
		return


# --- PUBLIC METHODS ---

func enter() -> void:
	pass


func exit() -> void:
	pass


# --- PRIVATE METHODS ---
