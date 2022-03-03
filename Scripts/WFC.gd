extends Node

var NO_INDEX = -1

enum Directions {
    FROM_TOP_TO_BOTTOM = 1,
    FROM_BOTTOM_TO_TOP = 2,
    FROM_RIGHT_TO_LEFT = 4,
    FROM_LEFT_TO_RIGHT = 8,
}

func _ready():
    # GLOBAL: ready
    randomize()
