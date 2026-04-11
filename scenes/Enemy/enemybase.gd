class_name EnemyBase
extends Area2D
@onready var animated_sprite=$AnimatedSprite2D
@export var health=1
@export var damage=10
@export var speed=30
var is_contact=false
var hit_flash_tween:Tween=null

var xp_drop_chance: float = 0.6
var gold_drop_chance: float = 0.3
var xp_scene: PackedScene = preload("res://scenes/xp/xp.tscn")
var gold_scene: PackedScene = preload("res://scenes/gold/gold.tscn")


var knockback_time: float = 0.3
var knockback_tween: Tween


var separation_radius: float = 100
var separation_weight: float = 1
var separation_area: Area2D
var separation_collision_shape: CollisionShape2D

var push_radius: float = 1
var max_pending_push: float = 12.0
var pending_push: Vector2 = Vector2.ZERO

func receive_push(push: Vector2) -> void:
	pending_push += push
	pending_push = pending_push.limit_length(max_pending_push)

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("enemy")
	
	_create_separation_area()

func _create_separation_area() -> void:
	separation_area = Area2D.new()
	separation_area.name = "SeparationArea"
	separation_area.collision_layer = 0
	separation_area.collision_mask = 2
	separation_area.monitoring = true
	separation_area.monitorable = false
	#separation_area.visible = false

	separation_collision_shape = CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = separation_radius
	separation_collision_shape.shape = circle

	separation_area.add_child(separation_collision_shape)
	add_child(separation_area)
	

func _physics_process(delta: float) -> void:
	if not GameManager.Player:
		return

	var chase_velocity := Vector2.ZERO
	if not is_contact:
		chase_velocity = (GameManager.Player.global_position - global_position).normalized() * speed

	var separation_velocity :Vector2= _get_separation_force() * separation_weight * speed
	var final_velocity := chase_velocity + separation_velocity
	
	final_velocity = final_velocity.limit_length(speed)
	if final_velocity.length_squared() < 0.0004:
		final_velocity = Vector2.ZERO

	global_position += final_velocity * delta
	if pending_push != Vector2.ZERO:
		global_position += pending_push
		pending_push = Vector2.ZERO

	if chase_velocity.x < -0.5:
		animated_sprite.flip_h = true
	elif chase_velocity.x > 0.5:
		animated_sprite.flip_h = false

	if final_velocity != Vector2.ZERO:
		animated_sprite.play("walk")

	if is_contact:
		apply_damage_to_player()
		
func _get_separation_force() -> Vector2:
	var push := Vector2.ZERO

	for other in separation_area.get_overlapping_areas():				
		if other == self or other.name == "SeparationArea":
			continue
			
		var other_pos := other.global_position		

		var away := global_position - other_pos
		var dist := away.length()

		if dist < separation_radius:
			var t := 1.0 - (dist / separation_radius)
			push += away.normalized() * t * t

	if push.length_squared() < 0.0004:
		return Vector2.ZERO

	return push

func _on_body_entered(body:CharacterBody2D):
	if body==GameManager.Player:
		is_contact=true
		apply_damage_to_player()

func _on_body_exited(body:CharacterBody2D):
	if body==GameManager.Player:
		is_contact=false


func apply_damage_to_player():
	if GameManager.Player and GameManager.Player.has_method("damage"):
		GameManager.Player.damage(damage)

func damage_enemy(amount:int, kb:int=40):
	health-=amount
	var direction=(global_position-GameManager.Player.global_position).normalized()
	flash_sprite()
	knockback_smooth(kb)
	if health<=0:
		die()

func knockback_smooth(kb:int) -> void:
	if knockback_tween:
		knockback_tween.kill()

	var away_dir: Vector2 = (global_position - GameManager.Player.global_position).normalized()

	knockback_tween = create_tween()
	knockback_tween.set_trans(Tween.TRANS_SINE)
	knockback_tween.set_ease(Tween.EASE_OUT)
	knockback_tween.tween_property(
		self,
		"global_position",
		global_position + away_dir * kb,
		knockback_time
	)


func flash_sprite():
	if hit_flash_tween:
		hit_flash_tween.kill()
	hit_flash_tween=create_tween()
	hit_flash_tween.tween_property(animated_sprite,"modulate",Color(4,4,4),0.05)
	hit_flash_tween.tween_property(animated_sprite,"modulate",Color.WHITE,0.05)
func die():
	drop_loot()
	knockback_smooth(40)
	await knockback_tween.finished
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
