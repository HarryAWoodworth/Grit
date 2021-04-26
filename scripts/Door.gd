extends "res://scripts/Actor.gd"

var open: bool
var locked: bool
var key: String

func init_door(open_: bool=false, locked_: bool=false, key_:String="nokey"):
	open = open_
	locked = locked_
	key = key_

func open():
	open = true
	# Change sprite and occluder

func close():
	open = false
	# Change sprite and occluder
	
# Return true if the door can be and is unlocked with the key 
func unlock(key_:String) -> bool:
	if locked and key_ == key:
		locked = false
		return true
	else:
		return false

# Return true if the door can be and is locked with the key 
func lock(key_:String) -> bool:
	if !locked and key_ == key:
		locked = true
		return true
	return false
