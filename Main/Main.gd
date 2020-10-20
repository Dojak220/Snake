extends Node

var score = 0
var map = []
var score_anterior = 0;
var scores_path="user://scores.dat"
var previous_score = {
	"scores": {
		"date": String(OS.get_datetime()),
		"value": 0
	},
	"best_score": 0
}


# Called when the node enters the scene tree for the first time.
func _ready():
	var file = File.new()
	previous_score = load("user://scores.dat")
	print("Scores:\n", previous_score)
	randomize()

func load(path):
	var file = File.new()
	save("",path)
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content

func best_score(new_score):
	var file = File.new()
	if file.file_exists(scores_path):
		file.open(scores_path, File.READ)
		var scores = file.get_var()
		file.close()
		print(score)
#		if new_score >= scores.best_score:
#			return new_score
#		else:
#			return score.best_score
		return 0

func save(content, path):
	print("Entrou em save()")
	var best_score = best_score(content)
		
	var score = {
		"scores": {
			"date": String(OS.get_datetime()),
			"value": content
		},
		"best_score": best_score
	}
	
	var file = File.new()
	
	if !file.file_exists(path):
		file.open(path, File.WRITE)
		file.store_string(String(OS.get_datetime(false))+"\n")
		file.close()
	file.open(path, File.WRITE)
	file.store_var(score)
	file.close()
	
	print("Data saved")

func start_game():
	print("\n", previous_score, "\n")
	print("Score da partida anterior: ", score_anterior)
	$SnakeHead.speed = $HUD/Speed.get_item_id($HUD/Speed.selected)
	$SnakeHead.can_move = true
	$HUD/Speed.disabled = true
	$HUD/Speed.hide()
	$HUD/Score.text = "0"
	$HUD/GameOver.visible = false
	$Alimento.visible = true

func gameover():
	score_anterior = score;
	print("Score da partida: ", score_anterior)
	save(score_anterior,scores_path)
	score = 0
	$SnakeHead.can_move = false
	$SnakeHead.snake_size = 0
	$SnakeHead.last_position = PoolVector2Array()
	$SnakeHead.position = $StartPosition.position
	$SnakeHead._ready()
	for i in range($SnakeHead.get_child_count()-2):
		$SnakeHead.get_child(i+2).queue_free()
	$Alimento._ready()
	$HUD/GameOver.show()
	$HUD/StartGame.disabled = false
	$HUD/StartGame.show()
	$HUD/Speed.disabled = false
	$HUD/Speed.show()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_pos(a):
	a.position.x = rand_range(a.player_size.x/2.0, a.vp_size.x - a.player_size.x/2.0)
	a.position.y = rand_range(a.player_size.y/2.0, a.vp_size.y - a.player_size.y/2.0)
	a.position = a.position.snapped(Vector2.ONE * a.tile_size)
	a.position += Vector2.ONE * a.tile_size/2
	is_occupied(a.position)

func is_occupied(position):
	if $SnakeHead.snake_size < $SnakeHead.vp_size.x * $SnakeHead.vp_size.y / $SnakeHead.tile_size:
		for i in $SnakeHead.last_position:
			if i == position:
				print("Spawnou embaixo da cobra")
				set_pos($Alimento)

func _on_Alimento_eat():
	score = score +1
	$HUD/Score.text = str(score)
	set_pos($Alimento)
	
