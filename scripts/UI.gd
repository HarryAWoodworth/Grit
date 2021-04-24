extends CanvasLayer

onready var EquippedWeapon1 = $PlayerInfo/EquippedWeapon
onready var EquippedWeapon2 = $PlayerInfo/EquippedWeapon2
onready var ArmorSlot1 = $PlayerInfo/Armor/ArmorSlot
onready var ArmorSlot2 = $PlayerInfo/Armor/ArmorSlot2
onready var ArmorSlot3 = $PlayerInfo/Armor/ArmorSlot3
onready var ArmorSlot4 = $PlayerInfo/Armor/ArmorSlot4
onready var ArmorSlot5 = $PlayerInfo/Armor/ArmorSlot5
onready var ArmorSlot6 = $PlayerInfo/Armor/ArmorSlot6
onready var ArmorSlot7 = $PlayerInfo/Armor/ArmorSlot7

var game

func init(game_):
	game = game_

func _on_EquippedWeapon_mouse_entered():
	if EquippedWeapon1.equipped:
		game.show_equipment_info_ui(EquippedWeapon1)
func _on_EquippedWeapon2_mouse_entered():
	if EquippedWeapon2.equipped:
		game.show_equipment_info_ui(EquippedWeapon2)
func _on_ArmorSlot_mouse_entered():
	print("UI: Mouse inside armor slot 1 (hands)")
	if ArmorSlot1.equipped:
		game.show_equipment_info_ui(ArmorSlot1)
func _on_ArmorSlot2_mouse_entered():
	print("UI: Mouse inside armor slot 2 (hands)")
	if ArmorSlot2.equipped:
		game.show_equipment_info_ui(ArmorSlot2)
func _on_ArmorSlot3_mouse_entered():
	print("UI: Mouse inside armor slot 3 (hands)")
	if ArmorSlot3.equipped:
		game.show_equipment_info_ui(ArmorSlot3)
func _on_ArmorSlot4_mouse_entered():
	print("UI: Mouse inside armor slot 4 (hands)")
	if ArmorSlot4.equipped:
		game.show_equipment_info_ui(ArmorSlot4)
func _on_ArmorSlot5_mouse_entered():
	print("UI: Mouse inside armor slot 5 (hands)")
	if ArmorSlot5.equipped:
		game.show_equipment_info_ui(ArmorSlot5)
func _on_ArmorSlot6_mouse_entered():
	print("UI: Mouse inside armor slot 6 (hands)")
	if ArmorSlot6.equipped:
		game.show_equipment_info_ui(ArmorSlot6)
func _on_ArmorSlot7_mouse_entered():
	print("UI: Mouse inside armor slot 7 (hands)")
	if ArmorSlot7.equipped:
		game.show_equipment_info_ui(ArmorSlot7)
