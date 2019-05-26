tool
extends Control

export (String) var text

onready var label = $PanelContainer/VSplitContainer/MarginContainer2/CenterContainer/Label
onready var confirm_button = $PanelContainer/VSplitContainer/MarginContainer/HBoxContainer/ConfirmButton
onready var reject_button = $PanelContainer/VSplitContainer/MarginContainer/HBoxContainer/RejectButton

signal confirmed

func _ready():
	label.text = self.text
	confirm_button.connect("pressed", self, "on_confirm_pressed")
	reject_button.connect("pressed", self, "on_reject_pressed")
	self.visible = false
	
func popup():
	self.visible = true
	
func on_confirm_pressed():
	emit_signal("confirmed")
	self.visible = false

func on_reject_pressed():
	self.visible = false