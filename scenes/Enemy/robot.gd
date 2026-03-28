extends Area2D
@onready var player
@onready var animated_sprite=$AnimatedSprite2D
var health=2
var damage=10
var speed=30
var is_contact=false
var damage_cooldown=1
var last_damage_time=0
@export var knockback_strength=200
@export var knockback_duration:float=0.2
var knockback_active:bool=false
var knockback_velocity:Vector2=Vector2.ZERO
var knockback_timer=0
@export var hit_flash_duration:float=0.3
var hit_flash_tween:Tween=null

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
		apply_damage_to_player()
		last_damage_time=Time.get_ticks_msec()/1000.0

func _process(delta):
	if knockback_active:
		global_position+=knockback_velocity*delta
		knockback_timer-=delta
		if knockback_timer<=0:
			knockback_active=false
		return
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
	if global_position.length()>0:
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
	var direction=(global_position-player.global_position).normalized()
	knockback_velocity=direction* knockback_strength
	knockback_timer=knockback_duration
	knockback_active=true
	flash_sprite()
	if health<=0:
		die()

func flash_sprite():
	if hit_flash_tween:
		hit_flash_tween.kill()
	hit_flash_tween=create_tween()
	hit_flash_tween.tween_property(animated_sprite,"modulate",Color.RED,hit_flash_duration*0.5)
	hit_flash_tween.tween_property(animated_sprite,"modulate",Color.WHITE,hit_flash_duration*0.5)
	
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
