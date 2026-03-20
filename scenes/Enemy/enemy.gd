extends Area2D
@onready var player
@onready var animated_sprite=$AnimatedSprite2D
var health=3
var damage=10
var speed=50
var is_contact=false




var xp_drop_chance: float = 0.6
var gold_drop_chance: float = 0.3
var xp_scene: PackedScene = preload("res://scenes/xp/xp.tscn")
var gold_scene: PackedScene = preload("res://scenes/gold/gold.tscn")



func _ready():
	player=get_tree().get_first_node_in_group("player")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var overlapping_bodies=get_overlapping_bodies()
	if player in overlapping_bodies:
		is_contact=true

func _process(delta):
	if player and not is_contact:
		move_toward_player(delta)

func move_toward_player(delta):
	var direction=(player.global_position-global_position).normalized()
	global_position+=direction*speed*delta
	
	if direction.x>0.3:
		animated_sprite.flip_h=false
	elif direction.x<-0.3:
		animated_sprite.flip_h=true
	if global_position.length()>0:
		animated_sprite.play("enemyanimation")

func _on_body_entered(body:CharacterBody2D):
	if body==player:
		is_contact=true
		player.damage(damage)
			
func _on_body_exited(body:CharacterBody2D):
	if body==player:
		is_contact=false

func damage_enemy(amount:int):
	health-=amount
	if health<=0:
		die()

func die():
	drop_loot()
	GameManager.SpawnManager.kill(self)


func drop_loot() -> void:
	var roll: float = randf()

	if roll > xp_drop_chance:
		return

	if roll > gold_drop_chance:
		var xp: Area2D = xp_scene.instantiate()
		xp.global_position = global_position
		get_tree().current_scene.get_node("Pickups").call_deferred("add_child", xp)
	else:
		var gold: Area2D = gold_scene.instantiate()
		gold.global_position = global_position
		get_tree().current_scene.get_node("Pickups").call_deferred("add_child", gold)
