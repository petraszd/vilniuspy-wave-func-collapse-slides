class_name WFCCollapser
extends Node2D


export(int) var num_cols = 1
export(int) var num_rows = 1

var tile_scene = preload("res://Scenes/WFCTile.tscn")
var tiles = []

func _ready():
    print("Collapser: ready")
    generate_tiles()


func generate_tiles():
    var screen_size = get_viewport().size
    print(screen_size)

    # TODO: Wrong. It depends on a screen size and on a num_cols, num_rows
    var w = screen_size.x
    var h = screen_size.y

    var x_delta = 0
    var y_delta = 0
    var x_size = min(w, h) / float(num_cols)
    var y_size = min(w, h) / float(num_rows)

    if h > w:
        y_delta = (h - w) / 2.0
    elif w > h:
        x_delta = (w - h) / 2.0

    for y in range(num_rows):
        for x in range(num_cols):
            var tile = tile_scene.instance()
            tile.idx = y * num_cols + x
            tile.global_position.x = x_delta + x * x_size
            tile.global_position.y = y_delta + y * y_size
            $Groups.add_child(tile)
            tiles.append(tile)
