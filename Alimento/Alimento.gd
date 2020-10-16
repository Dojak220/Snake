extends Area2D
#extends RigidBody2D

var vp_size                 # Guarda o tamanho da tela no viewport
var player_size             # Guarda o tamanho do player
var tile_size = 32          # Guarda o tamanho de cada célula dentro do mapa

signal eat

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	visible = false
	vp_size = get_viewport_rect().size
	player_size = $imagem.texture.get_size()
	set_pos()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_pos():
	position.x = rand_range(player_size.x/2.0, vp_size.x - player_size.x/2.0)
	position.y = rand_range(player_size.y/2.0, vp_size.y - player_size.y/2.0)
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	if(position == Vector2(16,16)):
		set_pos()

func _on_Alimento_area_entered(area):
	emit_signal("eat")
