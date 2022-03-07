extends Node


onready var PRunner = preload("res://NativeScripts/PythonRunner.gdns").new()


var NO_INDEX = -1

enum Directions {
    FROM_TOP_TO_BOTTOM = 1,
    FROM_BOTTOM_TO_TOP = 2,
    FROM_RIGHT_TO_LEFT = 4,
    FROM_LEFT_TO_RIGHT = 8,
}

const TRANSITION_ANIM_SPEED = 0.25

func _ready():
    # GLOBAL: ready
    randomize()
