extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready():
	$StartGame.show()
	$GameOver.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ScoreMessageTimer_timeout():
	$Score.text = "0"


func _on_StartGame_pressed():
	emit_signal("start_game")
	$StartGame.disabled = true
	$StartGame.hide()
