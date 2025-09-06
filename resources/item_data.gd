class_name ItemData extends Resource


@export var name: String
@export var texture: Texture2D
@export var dimentions: Vector2i
@export var is_rotated: bool = false

func load_data(data: Dictionary) -> void:
	name = data.name
	texture = load(data.texture)
	dimentions = data.dimentions
	is_rotated = data.is_rotated

func parse() -> Dictionary:
	return {
		"name": name,
		"texture": texture.resource_path,
		"dimentions": dimentions,
		"is_rotated": is_rotated,
	}
