extends Node


onready var collapser: WFCCollapser = get_node("WFCCollapser")


func _on_ResetButton_pressed():
    collapser.restore_state()

func _on_GenerateButton_pressed():
    collapser.generate()
