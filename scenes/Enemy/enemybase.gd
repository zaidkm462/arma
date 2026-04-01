class_name EnemyBase
extends Area2D
@onready var player
@onready var animated_sprite=$AnimatedSprite2D
@export var health=2
@export var damage=10
@export var speed=30
@export var correction_value=0.1
var is_contact=false
var knockback_strength=200
var knockback_duration:float=0.2
var knockback_active:bool=false
var knockback_velocity:Vector2=Vector2.ZERO
var knockback_timer=0
var hit_flash_tween:Tween=null
@export var separation_distance=70


var xp_drop_chance: float = 0.6
var gold_drop_chance: float = 0.3
var xp_scene: PackedScene = preload("res://scenes/xp/xp.tscn")
var gold_scene: PackedScene = preload("res://scenes/gold/gold.tscn")



func _ready():
	player=get_tree().get_first_node_in_group("player")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	add_to_group("enemy")

func _process(delta):
	if knockback_active:
		global_position+=knockback_velocity*delta
		knockback_timer-=delta
		if knockback_timer<=0:
			knockback_active=false
		return
	separate_from_enemies()
	if player and not is_contact:
		move_toward_player(delta)
	if is_contact and player:
		apply_damage_to_player()

func move_toward_player(delta):
	var direction=(player.global_position-global_position).normalized()
	global_position+=direction*speed*delta

	if direction.x>0.3:
		animated_sprite.flip_h=false
	elif direction.x<-0.3:
		animated_sprite.flip_h=true
	if global_position.length()>0:
		animated_sprite.play("walk")

func _on_body_entered(body:CharacterBody2D):
	if body==player:
		is_contact=true
		apply_damage_to_player()

func _on_body_exited(body:CharacterBody2D):
	if body==player:
		is_contact=false

func _on_area_entered(area:Area2D):
	if area.is_in_group("enemy"):
		var dir=(global_position-area.global_position).normalized()
		global_position+=dir*5

func separate_from_enemies():
	var overlapping=get_overlapping_areas()
	for area in overlapping:
		if area.is_in_group("enemy") and area!=self:
			var offset=global_position-area.global_position
			var dist=offset.length()
			if dist<separation_distance:
				var dir=offset.normalized()
				var correction=(separation_distance-dist)*correction_value
				global_position+=dir*correction

func apply_damage_to_player():
	if player and player.has_method("damage"):
		player.damage(damage)

func damage_enemy(amount:int):
	health-=amount
	var direction=(global_position-player.global_position).normalized()
	knockback_velocity=direction*knockback_strength
	knockback_timer=knockback_duration
	knockback_active=true
	flash_sprite()
	if health<=0:
		die()

func flash_sprite():
	if hit_flash_tween:
		hit_flash_tween.kill()
	hit_flash_tween=create_tween()
	hit_flash_tween.tween_property(animated_sprite,"modulate",Color(4,4,4),0.05)
	hit_flash_tween.tween_property(animated_sprite,"modulate",Color.WHITE,0.05)
	
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
