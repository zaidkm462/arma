extends Area2D
@onready var player
@onready var animated_sprite=$AnimatedSprite2D

var health=10
var damage=10
var speed=50
var is_contact=false
var damage_cooldown=1
var last_damage_time=0

<<<<<<< HEAD



var xp_drop_chance: float = 0.6
var gold_drop_chance: float = 0.3
var xp_scene: PackedScene = preload("res://scenes/xp/xp.tscn")
var gold_scene: PackedScene = preload("res://scenes/gold/gold.tscn")






var xp_drop_chance: float = 0.6
var gold_drop_chance: float = 0.3
var xp_scene: PackedScene = preload("res://scenes/xp/xp.tscn")
var gold_scene: PackedScene = preload("res://scenes/gold/gold.tscn")



=======
>>>>>>> parent of 2f0df8d (Revert "Update enemy.gd")
func _ready():
	player=get_tree().get_first_node_in_group("player")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var overlapping_bodies=get_overlapping_bodies()
	if player in overlapping_bodies:
		is_contact=true
		apply_damage_to_player()
		last_damage_time=Time.get_ticks_msec()/1000.0

func _process(delta):
	if player and not is_contact:
		move_toward_player(delta)
		
	if is_contact and player:
		var current_time=Time.get_ticks_msec()/1000.0
		if current_time-last_damage_time>=damage_cooldown:
			apply_damage_to_player()
			last_damage_time=current_time

func move_toward_player(delta):
	var direction=(player.global_position-global_position).normalized()
	global_position+=direction*speed*delta
	
	if direction.x>0.3:
		animated_sprite.flip_h=false
	elif direction.x<-0.3:
		animated_sprite.flip_h=true
	if global_position.length()>0.3:
		animated_sprite.play("enemyanimation")

func _on_body_entered(body:CharacterBody2D):
	if body==player:
		is_contact=true
		apply_damage_to_player()
		last_damage_time=Time.get_ticks_msec()/1000.0

func _on_body_exited(body:CharacterBody2D):
	if body==player:
		is_contact=false

func apply_damage_to_player():
	if player and player.has_method("damage"):
		player.damage(damage)

func damage_enemy(amount:int):
	health-=amount
	if health<=0:
		die()

func die():
	GameManager.SpawnManager.kill(self)
