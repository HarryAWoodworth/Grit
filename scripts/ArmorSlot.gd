extends Control

onready var Text = $RichTextLabel

func setText(string):
	Text.bbcode_text = string
