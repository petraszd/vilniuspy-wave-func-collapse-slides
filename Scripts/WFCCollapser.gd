class_name WFCCollapser
extends Control


export(int) var padding = 20

export(int) var num_cols = 1
export(int) var num_rows = 1

var tile_scene = preload("res://Scenes/WFCTile.tscn")
var tiles = []
var is_mouse_pressed: bool = false


func _ready():
    assert(num_cols > 0)
    assert(num_rows > 0)
    generate_tiles()
    rescale_groups_wrapper()

func _process(_delta):
    var prev_is_mouse_pressed = is_mouse_pressed
    is_mouse_pressed = Input.is_mouse_button_pressed(BUTTON_LEFT)

    var hovered_idx = process_mouse_position()
    if hovered_idx != WFC.NO_INDEX and not is_mouse_pressed and prev_is_mouse_pressed:
        tiles[hovered_idx].process_click()
        recursively_update_availability_flags(hovered_idx)

func process_mouse_position():
    var result = WFC.NO_INDEX
    var mouse_pos = $Groups.get_local_mouse_position()
    if (
        mouse_pos.x > 0.0 and
        mouse_pos.y > 0.0 and
        mouse_pos.x < num_cols and
        mouse_pos.y < num_rows
    ):
        var int_x = int(mouse_pos.x)
        var int_y = int(mouse_pos.y)
        var tile_idx = int_y * num_cols + int_x

        var is_hovered = tiles[tile_idx].process_local_mouse_position(
            mouse_pos - Vector2(int_x, int_y)
        )
        if is_hovered:
            result = tile_idx

    cleanup_hovered_from_all_tiles(result)
    return result

func cleanup_hovered_from_all_tiles(hovered_idx):
    for i in range(len(tiles)):
        if i != hovered_idx:
            tiles[i].remove_hovered_if_needed()

func recursively_update_availability_flags(tile_idx, depth = 0):
    var tile = tiles[tile_idx]
    var x0 = tile_idx % num_cols
    var y0 = tile_idx / num_cols

    if y0 < num_rows - 1:
        var to_bottom_idx = (y0 + 1) * num_cols + x0
        var dir = WFC.Directions.FROM_TOP_TO_BOTTOM
        if tiles[to_bottom_idx].mark_availability_flags(tile, dir, depth):
            recursively_update_availability_flags(to_bottom_idx, depth + 1)
    if y0 > 0:
        var to_top_idx = (y0 - 1) * num_cols + x0
        var dir = WFC.Directions.FROM_BOTTOM_TO_TOP
        if tiles[to_top_idx].mark_availability_flags(tile, dir, depth):
            recursively_update_availability_flags(to_top_idx, depth + 1)
    if x0 > 0:
        var to_left_idx = y0 * num_cols + x0 - 1
        var dir = WFC.Directions.FROM_RIGHT_TO_LEFT
        if tiles[to_left_idx].mark_availability_flags(tile, dir, depth):
            recursively_update_availability_flags(to_left_idx, depth + 1)
    if x0 < num_cols - 1:
        var to_right_idx = y0 * num_cols + x0 + 1
        var dir = WFC.Directions.FROM_LEFT_TO_RIGHT
        if tiles[to_right_idx].mark_availability_flags(tile, dir, depth):
            recursively_update_availability_flags(to_right_idx, depth + 1)

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
    var screen_size = get_global_rect().size

    if screen_size.x == 0 or screen_size.y == 0:
        return

    var screen_x = screen_size.x - padding * 2
    if screen_x < padding:
        screen_x = screen_size.x

    var screen_y = screen_size.y - padding * 2
    if screen_y < padding:
        screen_y = screen_size.y

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
