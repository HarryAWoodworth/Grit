extends VBoxContainer

onready var player_name = $PlayerName
onready var player_health = $PlayerHealth

func list_player_info(player):
	player_name.text = player.title
	player_health.text = "Health: " + str(player.health)
	
func update_health(health):
	player_health.text = "Health: " + str(health)
