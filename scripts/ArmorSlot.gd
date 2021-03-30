extends Control

onready var Text = $RichTextLabel

var equipped = true

func setText(string):
	Text.bbcode_text = string
