extends Control

export (String) var sceneName = "Level 1"

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_LinkButton_pressed():
	GameManager.reset_autoload()
	get_tree().change_scene(str("res://Scenes/" + sceneName + ".tscn"))
