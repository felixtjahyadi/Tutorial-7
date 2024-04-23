extends Area

func _on_Fruit_body_entered(body):
	if body == GameManager.player:
		GameManager.player.inventory.add_item("Fruit", 1)
		queue_free()
