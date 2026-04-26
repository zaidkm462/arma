extends CharacterBody2D
@onready var animated_sprite=$AnimatedSprite2D
@onready var health_bar = $HealthBar
@export var stats:playerstats
var is_vulnerable := true

var push_radius: float = 18
var player_push_share: float = 0.2
var enemy_push_share: float = 0.8
var max_push_per_enemy: float = 10.0


func _ready():
	GameManager.Player=self
	$Timer.timeout.connect(_on_vul_timeout)
	if stats and stats.current_health<=0:
		stats.current_health=stats.max_health
	
	update_vulnerability_timer()
	update_health_bar()
	

func _physics_process(delta):
	var direction=Input.get_vector("left","right","up","down")
	velocity=direction*stats.move_speed
	move_and_slide()
	resolve_enemy_push()

	if direction.x > 0:
		animated_sprite.flip_h = false
		animated_sprite.play("walk_side")
	elif direction.x < 0:
		animated_sprite.flip_h = true
		animated_sprite.play("walk_side")
	elif direction.y > 0:
		animated_sprite.play("walk_down")
	elif direction.y < 0:
		animated_sprite.play("walk_up")
	elif velocity.length() > 0:
		animated_sprite.play("walk_down")
	else:
		animated_sprite.stop()

func resolve_enemy_push() -> void:
	var total_player_push := Vector2.ZERO

	for enemy in GameManager.SpawnManager.alive_enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue

		var offset: Vector2 = enemy.global_position - global_position
		var dist: float = offset.length()

		if dist <= 0.001:
			offset = Vector2.RIGHT
			dist = 0.001

		var min_dist: float = push_radius + enemy.push_radius

		if dist < min_dist:
			var penetration: float = min_dist - dist
			var normal: Vector2 = offset / dist
			var correction: Vector2 = normal * min(penetration, max_push_per_enemy)

			total_player_push -= correction * player_push_share
			enemy.receive_push(correction * enemy_push_share)

	global_position += total_player_push

func damage(amount: int) -> void:
	if not is_vulnerable: return
	var mitigated_damage=max(1,amount-stats.armor)
	stats.current_health-=mitigated_damage
	stats.current_health=max(0,stats.current_health)
	AudioManager.play_damage_sound()
	update_health_bar()
	is_vulnerable = false
	$Timer.start()
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED,0.1)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE,0.1)
	print("Player took ",mitigated_damage," damage. HP left: ",stats.current_health)
	if stats.current_health<=0:
		AudioManager.disable_damage_sound()
		die()

func die():
	print("Player died")
	GameManager.lose_game()

func _on_vul_timeout() -> void: is_vulnerable = true

func update_vulnerability_timer() -> void:
	if stats: $Timer.wait_time = max(0.5, stats.vulnerablitiy)

func update_health_bar() -> void:
	if stats and health_bar:
		health_bar.set_health(stats.current_health, stats.max_health)

func init_powerups() -> void:
	var items : Dictionary[String,PassiveItem] = GameManager.PassivesManager.purchased_items
	for item:PassiveItem in items.values():		
		if not item.stat in self.stats: continue	
		
		self.stats.set(item.stat, self.stats.get(item.stat) + item.base_value * item.rank)		
		
		if item.stat in ["damage", "amount", "area_radius", "cool_down"]:
			var old_w_value = self.stats.get(item.stat)
			for w in GameManager.WeaponsManager.game_weapons.values():
				if item.stat in w:
					w.set(item.stat, old_w_value + item.base_value * item.rank)
	#print(">>>>>>", GameManager.WeaponsManager.game_weapons["mwand"].amount)


func update_powerups(stat: String, value) -> void:	
	if not stat in self.stats: return
	
	self.stats.set(stat, self.stats.get(stat) + value)
	
	if stat in ["damage", "amount", "area_radius", "cool_down"]:
		for w in GameManager.WeaponsManager.game_weapons.values():
			if stat in w:					
				w.set(stat, w.get(stat) + value)
