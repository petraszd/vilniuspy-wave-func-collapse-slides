extends Node


onready var collapser: WFCCollapser = get_node("WFCCollapser")
onready var generate_btn: Button = get_node("MarginContainer/VBoxContainer/GenerateButton")
onready var reset_btn: Button = get_node("MarginContainer/VBoxContainer/ResetButton")


func _ready():
    if generate_btn.connect("pressed", self, "_on_GenerateButton_pressed"):
        print("ERROR: can't connect generate button")
    if reset_btn.connect("pressed", self, "_on_ResetButton_pressed"):
        print("ERROR: can't connect reset button")

func _on_ResetButton_pressed():
    collapser.restore_state()

func _on_GenerateButton_pressed():
    collapser.generate()
