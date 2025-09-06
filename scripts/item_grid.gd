extends GridContainer

const SLOT_SIZE: int = 16

@export var dimentions: Vector2i = Vector2i.ZERO
@export var inventory_slot_scene: PackedScene

var cell_data: Array[Node] = []
var held_item_intersects: bool = false
func _ready() -> void:
	create_slots()
	init_cell_data()
	mouse_exited.connect(_on_mouse_exited)



func create_slots() -> void:
	self.columns = dimentions.y
	for y in dimentions.y:
		for x in dimentions.x:
			var inventory_slot = inventory_slot_scene.instantiate()
			add_child(inventory_slot)
			
func init_cell_data() -> void:
	cell_data.resize(dimentions.x * dimentions.y)
	cell_data.fill(null)

func attempt_to_add_item_data(item: Node) -> bool:
	var cell_index: int = 0
	while cell_index < cell_data.size():
		if item_fits(cell_index, item.data.dimentions):
			break
		cell_index += 1
	
	if cell_index >= cell_data.size():
		prints("item didn't fit at index", cell_index)
		return false
	
	for y in item.data.dimentions.y:
		for x in item.data.dimentions.x:
			cell_data[cell_index + x + y * columns] = item
	
	# should be somewhere else
	item.set_init_position(get_coords_from_slot_index(cell_index))
	return true
	
func item_fits(index: int, dimentions: Vector2i) -> bool:
	for y in dimentions.y:
		for x in dimentions.x:
			var curr_index = index + x + y * columns
			if curr_index >= cell_data.size():
				return false
				# index / columns == row, so we are comparing our width-wise slots if they are
				# on the same row
			var split = index / columns != (index + x) / columns
			if split:
				return false
			if cell_data[index + x + y * columns]:
				return false
	return true
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			var held_item = get_tree().get_first_node_in_group("held_item")
			# pick up item
			if !held_item:
				var cell_index = get_slot_index_from_coords(get_global_mouse_position(), 0)
				var item = cell_data[cell_index]
				
				if !item:
					return
				item.get_picked_up()
				remove_item_from_cell_data(item)
				
				highlight_slots(get_slot_index_from_coords(item.anchor_point), item.data.dimentions)
			# place item
			else:
				if !held_item_intersects: return
				var cell_index = get_slot_index_from_coords(held_item.anchor_point)
				var items = items_in_area(cell_index, held_item.data.dimentions)
				if items.size():
					# swap item
					if items.size() == 1:
						held_item.get_placed(get_coords_from_slot_index(cell_index))
						remove_item_from_cell_data(items[0])
						add_item_to_cell_data(cell_index, held_item)
						items[0].get_picked_up()
						highlight_slots(cell_index, items[0].data.dimentions)
					return
				
				add_item_to_cell_data(cell_index, held_item)
				held_item.get_placed(get_coords_from_slot_index(cell_index))
				unhighlight_slots()
				
				
	if event is InputEventMouseMotion:
		var held_item = get_tree().get_first_node_in_group("held_item")
		if held_item:
			detect_held_item_intersection(held_item)
			unhighlight_slots()
			highlight_slots(get_slot_index_from_coords(held_item.anchor_point), held_item.data.dimentions)
			if !held_item_intersects:
				unhighlight_slots()
				
				

#FIRST
func get_slot_index_from_coords(coords: Vector2i, offset: int = SLOT_SIZE / 2) -> int:
	coords -= Vector2i(self.global_position) - (Vector2i(offset, offset))
	coords = coords / 16
	var res = coords.x + coords.y * columns
	if res > dimentions.x * dimentions.y || res < 0:
		return - 1
	return res
# FIRST
func get_coords_from_slot_index(index: int) -> Vector2i:
	var row = index / columns
	var column = index % columns
	return Vector2i(global_position) + Vector2i(column * 16, row * 16)
	
func detect_held_item_intersection(held_item: Node) -> void:
	var h_rect = Rect2(held_item.anchor_point, held_item.size)
	var g_rect = Rect2(global_position, size)
	var inter_s = h_rect.intersection(g_rect).size
	held_item_intersects = (inter_s.x * inter_s.y) / (held_item.size.x * held_item.size.y) > 0.8
	
func remove_item_from_cell_data(item: Node) -> void:
	for i in cell_data.size():
		if cell_data[i] == item:
			cell_data[i] = null


func add_item_to_cell_data(index: int, item: Node) -> void:
	for y in item.data.dimentions.y:
		for x in item.data.dimentions.x:
			cell_data[index + x + y * columns] = item
			
func items_in_area(index: int, dimentions: Vector2i) -> Array:
	var items_in_the_way: Dictionary = {}
	for y in dimentions.y:
		for x in dimentions.x:
			var cell_index = index + x + y * columns
			var item = cell_data[index + x + y * columns]
			if !item:
				continue
			if !items_in_the_way.has(item):
				items_in_the_way[item] = true
	return items_in_the_way.keys() if items_in_the_way.size() else []
	
func highlight_slots(index: int, dimentions: Vector2i) -> void:
	for y in dimentions.y:
		for x in dimentions.x:
			if index + x + y * columns >= cell_data.size():
				continue
			get_child(index + x + y * columns).modulate = Color.WHITE * 1.6

func unhighlight_slots() -> void:
	for i in get_children():
		i.modulate = Color.WHITE
	pass

func _on_mouse_exited() -> void:
	unhighlight_slots()



		
	
