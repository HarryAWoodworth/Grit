extends VBoxContainer

onready var player_name = $PlayerName
onready var player_health = $PlayerHealth
onready var player_weapon = $PlayerWeapon

func list_player_info(player):
	player_name.text = player.title
	player_health.text = "Health: " + str(player.health)
	player_weapon.text = "Weapon: " + str(player.weapon)
	
func update_name(name):
	player_name.text = str(name)
	
func update_health(health):
	player_health.text = "Health: " + str(health)
	
func update_weapon(weapon):
	player_weapon.text = "Weapon: " + str(weapon)
	
