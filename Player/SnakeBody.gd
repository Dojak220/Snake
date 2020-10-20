extends Area2D

signal body_hit

func pos(pos):
	global_position.x = pos.x
	global_position.y = pos.y

func _on_SnakeBody_area_entered(area):
	hide()
	emit_signal("body_hit")
	$CollisionShape2D.set_deferred("disable", true)
