extends Control
@onready var add_item_button: Button = %AddItem
@onready var inventory: PanelContainer = $Inventory
@onready var save_inventory_button: Button = %Save
@onready var load_inventory_button: Button = %Load
@onready var clear_button: Button = %Clear
@export var items: Array[ItemData] = []
var cell_data = {}
func _ready() -> void:
	add_item_button.pressed.connect(_add_item)
	save_inventory_button.pressed.connect(save)
	load_inventory_button.pressed.connect(func() -> void: inventory.load_cell_data(cell_data))
	clear_button.pressed.connect(_on_clear)


func _add_item() -> void:
	var item = items.pick_random()
	inventory.add_item(item)

func save() -> void:
	cell_data = inventory.serialize_cell_data()
	print(cell_data)

func _on_clear() -> void:
	inventory.clear()
