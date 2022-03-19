extends Node


var items = []


func _ready():
    items.append(get_node("Fragments_1"))
    items.append(get_node("Fragments_2"))

    print("HELLO", items)
