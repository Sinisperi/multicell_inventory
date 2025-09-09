class_name InventoryItem extends Sprite2D

enum AnimationType {
	PLACE,
	PICK_UP,
	ROTATE,
	ROTATE_BACK
}
var data: ItemData = null
var is_picked: bool = false
var mouse_offset: Vector2 = Vector2.ZERO

var size: Vector2:
	get():
		return Vector2(data.dimentions.x, data.dimentions.y) * 16.0
var anchor_point: Vector2:
	get():
		var new_anchor = global_position - size / 2
		return new_anchor

var is_rotated: bool = false


func _ready() -> void:
	if data:
		texture = data.texture
		
			
			
	
func _process(delta: float) -> void:
	if is_picked:
		global_position = get_global_mouse_position() - mouse_offset

func set_init_position(pos: Vector2) -> void:
	if data.is_rotated:
		rotation_degrees = 90
	global_position = pos + size / 2
	anchor_point = global_position - size / 2
		
	
	
func get_picked_up() -> void:
	add_to_group("held_item")
	is_picked = true
	z_index = 10
	anchor_point = global_position - size / 2
	animate(AnimationType.PICK_UP)
	mouse_offset = get_global_mouse_position() - global_position
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
			if is_picked:
				do_rotation()

func get_placed(pos: Vector2i) -> void:
	is_picked = false
	global_position = pos + Vector2i(size / 2)
	remove_from_group("held_item")
	z_index = 0
	anchor_point = global_position - size / 2
	animate(AnimationType.PLACE)

func do_rotation() -> void:
	data.is_rotated = !data.is_rotated
	data.dimentions = Vector2i(data.dimentions.y, data.dimentions.x)
	
	if data.is_rotated:
		animate(AnimationType.ROTATE)
	else:
		animate(AnimationType.ROTATE_BACK)
	anchor_point = global_position - size / 2


func animate(animation: AnimationType) -> void:
	var ease = Tween.EASE_OUT
	var trans = Tween.TRANS_BACK
	var duration = 0.2
	match animation:
		AnimationType.PICK_UP:
			var tween = create_tween().set_ease(ease)
			tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1).set_trans(trans)
			await tween.finished
			tween.kill()
			var tween2 = create_tween().set_ease(ease)
			tween2.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(trans)
			await tween2.finished
			tween2.kill()
		AnimationType.PLACE:
			var tween = create_tween().set_ease(ease)
			tween.tween_property(self, "scale", Vector2(0.96, 0.96), 0.1).set_trans(trans)
			await tween.finished
			tween.kill()
			var tween2 = create_tween().set_ease(ease)
			tween2.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(trans)
			await tween2.finished
			tween2.kill()
		AnimationType.ROTATE:
			var tween = create_tween().set_ease(ease)
			tween.tween_property(self, "rotation_degrees", 90, duration).set_trans(trans)
			await tween.finished
			tween.kill()
		AnimationType.ROTATE_BACK:
			var tween = create_tween().set_ease(ease)
			tween.tween_property(self, "rotation_degrees", 0, duration).set_trans(trans)
			await tween.finished
			tween.kill()
		_:
			return
