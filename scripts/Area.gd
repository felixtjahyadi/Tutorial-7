extends Area

export (String) var sceneName = "Level 1"


func _on_Area_body_entered(body):
	if body.get_name() == "Player":
		var current_scene = get_tree().get_current_scene()
		var player = get_node("/root/Level 1/Player")
		if current_scene.get_filename() == ("res://Scenes/" + sceneName + ".tscn"):
			GameManager.reset_autoload()
		player.inventory.clear_items()
		ResourceSaver.save("user://inventory.tres", player.inventory)
		get_tree().change_scene(str("res://Scenes/" + sceneName + ".tscn"))
