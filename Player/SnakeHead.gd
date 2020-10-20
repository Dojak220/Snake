extends Area2D

const SnakeBodyResource = preload("res://Player/SnakeBody.tscn")

# VARIÁVEIS
export var speed = 30       # Velocidade do personagem
var vp_size                 # Guarda o tamanho da tela no viewport
var player_size             # Guarda o tamanho do player
var moving = [false, ""]    # Guarda o estado do movimento do personagem: se ele está se movendo e em qual direção
var tile_size = 32          # Guarda o tamanho de cada célula dentro do mapa
var inputs = {"ui_right": Vector2.RIGHT, #Vector2(1,0)
			"ui_left": Vector2.LEFT,     #Vector2(-1,0)
			"ui_up": Vector2.UP,         #Vector2(0,1)
			"ui_down": Vector2.DOWN}     #Vector2(0,-1)
var snake_size = 0
var last_position = PoolVector2Array()
var can_move = false        # Será controlado pela main, a partir do new_game() ou game_over()
var counter = 0
var turning = false

# SINAIS
signal hit

func _unhandled_input(event):
	if can_move and !turning:
		for dir in inputs.keys():
			if event.is_action_pressed(dir):
				if moving[1] != "" && inputs[moving[1]] == -inputs[dir]:
					return
				moving = [true, dir]
				turning = true
				

# Realiza a movimentação do personagem. Enquanto o estado guardado em moving, o movimento acontece a cada frame.
# Em outras palavras, o player andará em uma direção indefinitivamente até que o valor de moving seja mudado, isto é,
# até que outra tecla seja pressionada.
func path(delta):
	if(counter >= delta * 10000/speed):
		if moving[0] == true:
			if(moving[1] == "ui_left"):
				position += inputs[moving[1]] * tile_size  #(-1,0) * tile_size
			if(moving[1] == "ui_right"):
				position += inputs[moving[1]] * tile_size  #(1,0) * tile_size
			if(moving[1] == "ui_up"):
				position += inputs[moving[1]] * tile_size  #(0,-1) * tile_size
			if(moving[1] == "ui_down"):
				position += inputs[moving[1]] * tile_size  #(0,1) * tile_size
			turning = false
		update_last_positions(position)
		if (snake_size > 0):
			update_children_positions()
		counter = 0
	counter += 1

func _ready():
	vp_size = get_viewport_rect().size
	player_size = $imagem.texture.get_size()
	position = position.snapped(Vector2.ZERO * tile_size)
	position += Vector2.ONE * tile_size/2
	last_position.append(position)
	moving = [false, ""]

func update_last_positions(new_position):
	var arrayinv = last_position
	arrayinv.invert()    # insert() pode tirar a necessidade de usar esse invert()
	for i in range(snake_size):
		if(i < snake_size):
			arrayinv[i] = arrayinv[i+1]
	arrayinv[-1] = new_position
	arrayinv.invert()
	last_position = arrayinv

func update_children_positions():
	for i in range(snake_size):
		get_child(i+2).global_position = last_position[i+1]

func _process(delta):
	path(delta)

# Conjunto de if's que emitem um sinal e enviam o conteúdo da mensagem que identifica a direção
# que o player fujão foi ao sair da tela.
	if position.x > vp_size.x:
		position.x = 0
		position = position.snapped(Vector2.RIGHT * tile_size) + Vector2.RIGHT * tile_size/2
	elif position.x < 0:
		position.x = vp_size.x
		position = position.snapped(Vector2.LEFT * tile_size) + Vector2.LEFT * tile_size/2
	elif position.y > vp_size.y:
		position.y = 0
		position = position.snapped(Vector2.DOWN * tile_size) + Vector2.DOWN * tile_size/2
	elif position.y < 0:
		position.y = vp_size.y
		position = position.snapped(Vector2.UP * tile_size) + Vector2.UP * tile_size/2
	else:
		return
	update_last_positions(position)
	if (snake_size > 0):
		update_children_positions()

func _on_Player_body_entered(): # arg: body
	hide()
	emit_signal("hit")
	$CollisionShape2D.set_deferred("disable", true)

func _on_Alimento_eat():
	var arrayinv
	arrayinv = last_position
	arrayinv.invert()
	arrayinv.append(position)
	arrayinv.invert()
	last_position = arrayinv
	snake_size += 1
	var SnakeBody = SnakeBodyResource.instance()
	SnakeBody.pos(-inputs[moving[1]] * tile_size)
	add_child(SnakeBody)
	get_child(snake_size+1).connect("body_hit", self, "_on_SnakeBody_hit")
	
func _on_SnakeBody_hit():
	emit_signal("hit")
#	for i in range(get_child_count()-2):
#		get_child(i+2).queue_free()
