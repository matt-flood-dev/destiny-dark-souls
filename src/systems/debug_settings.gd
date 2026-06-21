class_name DebugSettings

# --- SIGNALS ---


# --- CONFIGURATION & EXPORTS ---

const ENABLED: bool = true


# --- DATA & REFERENCES ---


# --- LIFECYCLE CALLBACKS ---


# --- INPUT HANDLING ---


# --- UPDATE LOOPS ---


# --- PUBLIC METHODS ---

static func log(message: String) -> void:
	if ENABLED:
		print(message)


# --- PRIVATE METHODS ---
