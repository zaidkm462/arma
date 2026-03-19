extends Area2D
@onready var animated_sprite=$AnimatedSprite2D
@export var health=10
@export var attack_damage=5
@export var speed=100
@export var separation_strength=50
var player
var can_damage=true
@onready var damage_cooldown=$DamageCooldown

func _ready():
	body_entered.connect(_on_body_entered)
	player = get_tree().get_first_node_in_group("player")
	if damage_cooldown:
		damage_cooldown.timeout.connect(_on_damage_cooldown_timeout)
	add_to_group("enemy")

func _physics_process(delta):
	if player == null:
		return
	var direction=(player.global_position-global_position).normalized()
	var desired_movement=direction*speed*delta
	
	var separation=Vector2.ZERO
	var nearby_enemies=get_overlapping_areas()
	for enemy in nearby_enemies:
		if enemy.is_in_group("enemy") and enemy!=self:
			var diff=global_position-enemy.global_position
			var distance=diff.length()
			if distance>0:
				separation+=diff.normalized()/distance
	
	if separation.length()>0:
		separation=separation.normalized()*separation_strength*delta
		desired_movement+=separation
	global_position+=desired_movement
	
	if direction.x>0:
		animated_sprite.flip_h=false
	elif direction.x<0:
		animated_sprite.flip_h=true
	if desired_movement.length()>0:
		animated_sprite.play("enemyanimation")

func _on_body_entered(body):
	if body==player and can_damage:
		if body.has_method("damage"):
			body.damage(attack_damage)
		can_damage=false
		if damage_cooldown:
			damage_cooldown.start()

func damage(amount:int):
	health-=amount
	if health<=0:
		die()

func die():
	SpawnManager.kill(self)
	queue_free()

func _on_damage_cooldown_timeout():
	can_damage = true
