extends VBoxContainer

onready var player_name = $PlayerName

func list_player_info(player):
	player_name = player.title
	# player_health = player.health
	# 
	
func update_health(newVal):
	pass
