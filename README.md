# Tutorial 7 - Basic 3D Game Mechanics & Level Design

Name : Felix Tjahyadi

NPM : 2106638614

Godot version : 3.5

# Latihan Mandiri

## Pick Up Item & Inventory
Dalam latihan ini, saya menambahkan kemampuan pemain untuk dapat pick up item yang ada dalam map dan juga masuk ke dalam sebuah inventory pemain. Dalam pembuatan bagian ini, saya melakukan beberapa langkah.

### Langkah 1: Item & Item Database
- Pertama saya akan membuah sebuah objek yang dapat diambil oleh pemain. Dalam hal ini, saya akan membuat sebuah buah atau Fruit sebagai pick up item.
- Untuk Item tesebut saya akan buat sebuah script default untuk item dalam bentuk Resource sebagai berikut:
```
extends Resource
class_name ItemResource

export var name: String
export var stackable: bool=false
export var max_stack: int = 99

enum ItemType {GENERIC, CONSUMABLE}
export(ItemType) var type
export var texture: Texture
export var mesh: Mesh
```
- Dengan memanfaatkan Resource tersebut kita dapat membuat banyak Item Resource dengan konfigurasi tertentu yang sama. Resource tersebut akan dikumpulkan dalam folder terpisah sehingga nantinya dapat kita masukkan langsung ke dalam database.
- Kemudian saya membuat sebuah script Item Database yang akan di autoload dalam permainan. Script tersebut akan melakukan iterasi terhadap folder Resource untuk menyimpan seluruh item.
```
extends Node

var items = Array()

func _ready():
	var directory = Directory.new()
	directory.open("res://Items")
	directory.list_dir_begin()
	
	var filename = directory.get_next()
	while(filename):
		if not directory.current_is_dir():
			items.append(load("res://Items/%s" % filename))
		
		filename = directory.get_next()
		
func get_item(item_name):
	for i in items:
		if i.name == item_name:
			return i
	
	return null
```
- Terakhir saya buat scene baru untuk item 'Fruit' berupa bentuk/rupa nya yang mana akan memiliki sebuah script yang akan menambahkan item tersebut ke dalam inventory
```
extends Area

func _on_Fruit_body_entered(body):
	if body == GameManager.player:
		GameManager.player.inventory.add_item("Fruit", 1)
		queue_free()
```

### Langkah 2: Inventory
- Langkah berikutnya kita akan membuat sebuah inventory yang akan dipakai oleh pemain. Saya membuat script yang akan menghandle setiap aksi dari inventory tersebut.
```
extends Resource
class_name Inventory

signal inventory_changed

export var _items = Array() setget set_items, get_items

func set_items(new_items):
	_items = new_items
	emit_signal("inventory_changed", self)
	
func get_items():
	return _items
	
func get_item(index):
	return _items[index]
	
func add_item(item_name, quantity):
	if quantity<=0:
		print("cant add negative")
		return
	
	var item = ItemDatabase.get_item(item_name)
	if not item:
		print("No item found")
		return
		
	var remaining_quantity = quantity
	var item_max_stack = item.max_stack if item.stackable else 1
	
	if item.stackable:
		for i in range(_items.size()):
			if remaining_quantity ==0:
				break
			
			var inventory_item = _items[i]
			
			if inventory_item.item_reference.name != item.name:
				continue
				
			if inventory_item.quantity < item_max_stack:
				var original_quantity = inventory_item.quantity
				inventory_item.quantity = min(original_quantity + remaining_quantity, item_max_stack)
				remaining_quantity -= inventory_item.quantity - original_quantity
				
	while remaining_quantity >0:
		var new_item = {
			item_reference = item,
			quantity = min(remaining_quantity, item_max_stack)
		}
		_items.append(new_item)
		remaining_quantity -= new_item.quantity
		
	emit_signal("inventory_changed", self)

func clear_items():
	_items.clear()

```
- Kemudian kita perlu tambahkan script tersebut ke dalam script untuk pemain.
```
var inventory_resource = load("res://scripts/Inventory.gd")
var inventory = inventory_resource.new()
```
- Terakhir kita akan buat sebuah UI simple untuk inventory pemain yang mana terdiri atas sebuah node Panel dan GridContainer dengan sebuah script untuk menambahkan dan menampilkan Item.
```
extends GridContainer

func _ready():
	GameManager.connect("player_initialized", self, "_on_player_initialized")
	
func _on_player_initialized(player):
	player.inventory.connect("inventory_changed", self, "_on_player_inventory_changed")
	
func _on_player_inventory_changed(inventory):
	for i in get_children():
		i.queue_free()
	
	for item in inventory.get_items():
		var item_label = Label.new()
		item_label.text = "%s x%d" % [item.item_reference.name, item.quantity]
		add_child(item_label)

```

### Langkah 3: Game Manager (Initialized Player's Inventory)
- Langkah terakhir adalah untuk dapat men-load inventory yang dimiliki oleh pemain secara autoload dengan sebuah script
```
extends Node

signal player_initialized

var player

func _process(delta):
	if not player:
		initialized_player()
		return
		
func initialized_player():
	player = get_tree().get_root().get_node("/root/Level 1/Player")
	if not player:
		return
	emit_signal("player_initialized", player)
	
	player.inventory.connect("inventory_changed", self, "_on_player_inventory_changed")
	
	var existing_inventory = load("user://inventory.tres")
	if existing_inventory:
		player.inventory.set_items(existing_inventory.get_items())
	
func _on_player_inventory_changed(inventory):
	ResourceSaver.save("user://inventory.tres", inventory)

func reset_autoload():
	player = null
```
- Dalam script tersebut akan menghandle setiap kasus berkaitan dengan inventory dan juga menyimpan inventory tersebut dan dapat dipakai terus menerus.

## Sprint & Crouching
Dalam latihan ini juga saya menambahkan fitur untuk melakukan sprint dan juga crouching yang mana saya membuat tambahan dalam script untuk mengatur kondisi pemain untuk menambahkan atau mengurangi kecepatan.

Berikut tmabahan script:
```
export var sprint_speed = 30
export var crouch_speed = 5

var is_sprinting = false  
var is_crouching = false  
```
```
func _input(event):
---------------------------------------------------------------------
    if Input.is_action_pressed("sprint"):
        is_sprinting = true
    else:
        is_sprinting = false
    if Input.is_action_pressed("crouch"):
		is_crouching = true
	else:
		is_crouching = false
```
```
func _physics_process(delta):
---------------------------------------------------------------------
    var current_speed = speed
        if is_sprinting:
            current_speed = sprint_speed
        elif is_crouching:
            current_speed = crouch_speed
            
    velocity = velocity.linear_interpolate(movement_vector * current_speed, acceleration * delta)
```