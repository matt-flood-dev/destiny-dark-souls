class_name WeaponDefinitions

enum Frame {
	PISTOL,
	RIFLE,
	SPECIAL,
	HEAVY,
}

enum Configuration {
	PISTOL_SIDEARM,
	PISTOL_REVOLVER,
	RIFLE_CARBINE,
	RIFLE_SNIPER,
	SPECIAL_SHOTGUN,
	SPECIAL_GRENADE_LAUNCHER,
	HEAVY_ROCKET_LAUNCHER,
	HEAVY_MINIGUN,
}

const MAX_EQUIPPED_FRAMES: int = 3
const SLOT_EMPTY: int = -1


static func get_frame_display_name(frame: Frame) -> String:
	match frame:
		Frame.PISTOL:
			return "Pistol"
		Frame.RIFLE:
			return "Rifle"
		Frame.SPECIAL:
			return "Special"
		Frame.HEAVY:
			return "Heavy"
		_:
			return "Unknown"


static func get_all_frames() -> Array[Frame]:
	return [
		Frame.PISTOL,
		Frame.RIFLE,
		Frame.SPECIAL,
		Frame.HEAVY,
	]


static func get_configurations_for_frame(frame: Frame) -> Array[Configuration]:
	match frame:
		Frame.PISTOL:
			return [Configuration.PISTOL_SIDEARM, Configuration.PISTOL_REVOLVER]
		Frame.RIFLE:
			return [Configuration.RIFLE_CARBINE, Configuration.RIFLE_SNIPER]
		Frame.SPECIAL:
			return [Configuration.SPECIAL_SHOTGUN, Configuration.SPECIAL_GRENADE_LAUNCHER]
		Frame.HEAVY:
			return [Configuration.HEAVY_ROCKET_LAUNCHER, Configuration.HEAVY_MINIGUN]
		_:
			return []


static func get_frame_for_configuration(configuration: Configuration) -> Frame:
	match configuration:
		Configuration.PISTOL_SIDEARM, Configuration.PISTOL_REVOLVER:
			return Frame.PISTOL
		Configuration.RIFLE_CARBINE, Configuration.RIFLE_SNIPER:
			return Frame.RIFLE
		Configuration.SPECIAL_SHOTGUN, Configuration.SPECIAL_GRENADE_LAUNCHER:
			return Frame.SPECIAL
		Configuration.HEAVY_ROCKET_LAUNCHER, Configuration.HEAVY_MINIGUN:
			return Frame.HEAVY
		_:
			return Frame.PISTOL


static func get_configuration_display_name(configuration: Configuration) -> String:
	match configuration:
		Configuration.PISTOL_SIDEARM:
			return "Sidearm"
		Configuration.PISTOL_REVOLVER:
			return "Revolver"
		Configuration.RIFLE_CARBINE:
			return "Carbine"
		Configuration.RIFLE_SNIPER:
			return "Sniper"
		Configuration.SPECIAL_SHOTGUN:
			return "Shotgun"
		Configuration.SPECIAL_GRENADE_LAUNCHER:
			return "Grenade Launcher"
		Configuration.HEAVY_ROCKET_LAUNCHER:
			return "Rocket Launcher"
		Configuration.HEAVY_MINIGUN:
			return "Minigun"
		_:
			return "Unknown"
