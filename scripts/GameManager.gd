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
