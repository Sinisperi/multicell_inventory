class_name Inventory extends PanelContainer

@export var inventory_item_scene: PackedScene
@export var items: Array[ItemData] = []
@onready var item_holder: Control = %ItemHolder
@onready var item_grid: GridContainer = %ItemGrid
var iter: int = 1000
func _ready() -> void:
	while iter:
		for i in items:
			add_item(i)
		iter -= 1


func add_item(item_data: ItemData) -> void:
	var inventory_item = inventory_item_scene.instantiate()
	inventory_item.data = item_data.duplicate()
	item_holder.add_child(inventory_item)
	var success = item_grid.attempt_to_add_item_data(inventory_item)
	#if !success:
		#inventory_item.queue_free()
		
func serialize_cell_data() -> Dictionary:
	var res = {}
	for i in item_grid.cell_data:
		if !i: continue
		var item_origin_slot = item_grid.get_slot_index_from_coords(i.anchor_point, 0)
		if item_origin_slot in res:
			continue
			
		res[item_origin_slot] = i.data.parse()
	return res
		
func load_cell_data(new_cell_data: Dictionary) -> void:
	for key in new_cell_data:
		var item_data = ItemData.new()
		item_data.load_data(new_cell_data[key])
		var inventory_item = inventory_item_scene.instantiate()
		inventory_item.data = item_data
		
		item_grid.add_item_to_cell_data(key, inventory_item)
		item_holder.add_child(inventory_item)
		inventory_item.set_init_position(item_grid.get_coords_from_slot_index(key))

func clear() -> void:
	item_grid.cell_data.fill(null)
	while item_holder.get_child_count():
		var item = item_holder.get_child(-1)
		item_holder.remove_child(item)
		item.queue_free()
