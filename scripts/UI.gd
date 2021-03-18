extends CanvasLayer

onready var EquippedWeapon1 = $PlayerInfo/EquippedWeapon
onready var EquippedWeapon2 = $PlayerInfo/EquippedWeapon2

var game

func init(game_):
	game = game_

func _on_EquippedWeapon_mouse_entered():
	game.show_equipment_info_ui(EquippedWeapon1)

func _on_EquippedWeapon2_mouse_entered():
	game.show_equipment_info_ui(EquippedWeapon2)
