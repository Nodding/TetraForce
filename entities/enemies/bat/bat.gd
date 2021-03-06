extends Enemy

var movetimer_length = 30
var movetimer = 0

onready var detect = $PlayerDetect

func _ready():
	MAX_HEALTH = 0.5
	DAMAGE = 0.5
	health = MAX_HEALTH

func _physics_process(delta):
	var sees_player = false
	if !network.is_map_host() || is_dead():
		return
	for body in detect.get_overlapping_bodies():
		if body is Player:
			sees_player = true
			if !anim.is_playing() && anim.assigned_animation != "sees_player":
				anim.play("sees_player")
	if !sees_player && anim.assigned_animation != "no_player":
		anim.play("no_player")

	loop_movement()
	loop_spritedir()
	loop_damage()
	loop_holes()

	if movetimer > 0:
		movetimer -= 1
	if movetimer == 10:
		movedir = Vector2.ZERO
	if movetimer == 0 && sees_player || is_on_wall():
		var players = get_tree().get_nodes_in_group("player")
		var shortest_distance = 999999
		var closest_player = null
		for player in players:
			if position.distance_to(player.position) < shortest_distance:
				shortest_distance = position.distance_to(player.position)
				closest_player = player
		movedir = Vector2(-1,0).rotated(position.angle_to_point(closest_player.position))
		movetimer = movetimer_length
