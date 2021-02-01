extends Node

# Loads Item nodes from a text file.

var item_dictionary = {}

func load_item(item_name):
	return item_dictionary.get(item_name,null)
