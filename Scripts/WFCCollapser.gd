class_name WFCCollapser
extends Control


export(int) var padding = 20

export(int) var num_cols = 1
export(int) var num_rows = 1

var tile_scene = preload("res://Scenes/WFCTile.tscn")
var tiles = []


func _ready():
    assert(num_cols > 0)
    assert(num_rows > 0)
    generate_tiles()
    rescale_groups_wrapper()

func _process(_delta):
    process_mouse_position()

func process_mouse_position():
    var mouse_pos = $Groups.get_local_mouse_position()
    if (
        mouse_pos.x <= 0.0 or
        mouse_pos.y <= 0.0 or
        mouse_pos.x >= num_cols or
        mouse_pos.y >= num_rows
    ):
        return

    var int_x = int(mouse_pos.x)
    var int_y = int(mouse_pos.y)
    var tile_idx = int_y * num_cols + int_x
    tiles[tile_idx].process_local_mouse_position(
        mouse_pos - Vector2(int_x, int_y)
    )

func generate_tiles():
    for y in range(num_rows):
        for x in range(num_cols):
            var tile = tile_scene.instance()
            tile.idx = y * num_cols + x
            $Groups.add_child(tile)
            tile.position.x = x
            tile.position.y = y
            tiles.append(tile)

func rescale_groups_wrapper():
    #var screen_size = get_viewport().size
    var screen_size = get_global_rect().size

    if screen_size.x == 0 or screen_size.y == 0:
        return

    var screen_x = screen_size.x - padding * 2
    if screen_x < padding:
        screen_x = screen_size.x

    var screen_y = screen_size.y - padding * 2
    if screen_y < padding:
        screen_y = screen_size.y

    # TODO: screen size padding

    var x_ratio = screen_x / num_cols
    var y_ratio = screen_y / num_rows
    var ratio = min(x_ratio, y_ratio)

    var x_delta = padding
    var y_delta = padding

    if x_ratio < y_ratio:
        y_delta += (screen_y - num_rows * ratio) * 0.5
    elif y_ratio < x_ratio:
        x_delta += (screen_x - num_cols * ratio) * 0.5

    $Groups.scale.x = ratio
    $Groups.scale.y = ratio

    $Groups.position.x = x_delta
    $Groups.position.y = y_delta
