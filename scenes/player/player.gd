extends CharacterBody2D
@onready var animated_sprite=$AnimatedSprite2D
@onready var health_bar = $HealthBar
@export var stats:playerstats
var is_vulnerable := true

func _ready():
	GameManager.Player=self
	$Timer.timeout.connect(_on_vul_timeout)
	update_vulnerability_timer()
	update_health_bar()
	if stats and stats.current_health<=0:
		stats.current_health=stats.max_health

func _physics_process(delta):
	var direction=Input.get_vector("left","right","up","down")
	velocity=direction*stats.move_speed
	move_and_slide()
	


	if direction.x>0:
		animated_sprite.flip_h=false
	elif direction.x<0:
		animated_sprite.flip_h=true
	if velocity.length()>0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")


func damage(amount: int) -> void:
	if not is_vulnerable: return
	var mitigated_damage=max(1,amount-stats.armor)
	stats.current_health-=mitigated_damage
	stats.current_health=max(0,stats.current_health)
	update_health_bar()
	is_vulnerable = false
	$Timer.start()
	print("Player took ",mitigated_damage," damage. HP left: ",stats.current_health)
	if stats.current_health<=0:
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
