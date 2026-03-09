extends CharacterBody2D
@onready var animated_sprite=$AnimatedSprite2D
@export var stats:playerstats
func _ready():
	GameManager.Player=self
	if stats and stats.current_health<=0:
		stats.current_health=stats.max_health
func _physics_process(delta):
	var direction=Input.get_vector("left","right","up","down")
	velocity=direction*100
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
	var mitigated_damage=max(1,amount-stats.armor)
	stats.current_health-=mitigated_damage
	stats.current_health=max(0,stats.current_health)
	print("Player took ",mitigated_damage," damage. HP left: ",stats.current_health)
	if stats.current_health<=0:
		die()
func die():
	print("Player died")
	queue_free()
