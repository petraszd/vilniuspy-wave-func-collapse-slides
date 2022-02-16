class_name WFCTile
extends Node2D


var idx: int


func _ready():
    set_name("Tile %d" % idx)


func _draw():
    var line_color = Color(1.0, 0.0, 0.0)
    draw_line(Vector2(0, 0), Vector2(1, 0), line_color)
    draw_line(Vector2(1, 0), Vector2(1, 1), line_color)
    draw_line(Vector2(1, 1), Vector2(0, 1), line_color)
    draw_line(Vector2(0, 1), Vector2(0, 0), line_color)
