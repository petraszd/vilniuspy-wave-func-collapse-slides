class_name WFCCollapser
extends Control


signal tiles_state_changed(tiles, num_cols, num_rows)


export(int) var image_data_idx = 0
export(int) var padding = 20
export(int) var num_cols = 1
export(int) var num_rows = 1
export(bool) var allow_select_unavailable = false
export(bool) var is_instant_generation = true

var tile_scene = preload("res://Scenes/WFCTile.tscn")
var tiles = []
var is_mouse_pressed: bool = false
var image_data: WFCImageData = null

onready var groups: Node2D = get_node("Wrapper/Groups")
onready var wrapper: Node2D = get_node("Wrapper")
onready var tile_errors: Node2D = get_node("Wrapper/TileErrors")


func _ready():
    assert(num_cols > 0)
    assert(num_rows > 0)
    image_data = WFCImageDataProvider.items[image_data_idx]

    generate_tiles()
    rescale_groups_wrapper()

    tile_errors.image_data = image_data
    assert(connect("tiles_state_changed", tile_errors, "_on_tiles_state_changed", [tiles, num_cols, num_rows]) == 0)

func _process(_delta):
    var prev_is_mouse_pressed = is_mouse_pressed
    is_mouse_pressed = Input.is_mouse_button_pressed(BUTTON_LEFT)

    var hovered_idx = process_mouse_position()
    if hovered_idx != WFC.NO_INDEX and not is_mouse_pressed and prev_is_mouse_pressed:
        tiles[hovered_idx].process_click()
        recursively_update_availability_flags(hovered_idx)
        emit_signal("tiles_state_changed")

func _on_self_resized():
    if wrapper != null:
        rescale_groups_wrapper()

func process_mouse_position():
    var result = WFC.NO_INDEX
    var mouse_pos = groups.get_local_mouse_position()
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

func recursively_update_availability_flags(tile_idx):
    var tile = tiles[tile_idx]
    var x0 = tile_idx % num_cols
    var y0 = tile_idx / num_cols

    if y0 < num_rows - 1:
        var to_bottom_idx = (y0 + 1) * num_cols + x0
        var dir = WFC.Directions.FROM_TOP_TO_BOTTOM
        if tiles[to_bottom_idx].mark_availability_flags(tile, dir):
            recursively_update_availability_flags(to_bottom_idx)
    if y0 > 0:
        var to_top_idx = (y0 - 1) * num_cols + x0
        var dir = WFC.Directions.FROM_BOTTOM_TO_TOP
        if tiles[to_top_idx].mark_availability_flags(tile, dir):
            recursively_update_availability_flags(to_top_idx)
    if x0 > 0:
        var to_left_idx = y0 * num_cols + x0 - 1
        var dir = WFC.Directions.FROM_RIGHT_TO_LEFT
        if tiles[to_left_idx].mark_availability_flags(tile, dir):
            recursively_update_availability_flags(to_left_idx)
    if x0 < num_cols - 1:
        var to_right_idx = y0 * num_cols + x0 + 1
        var dir = WFC.Directions.FROM_LEFT_TO_RIGHT
        if tiles[to_right_idx].mark_availability_flags(tile, dir):
            recursively_update_availability_flags(to_right_idx)

func generate_tiles():
    for y in range(num_rows):
        for x in range(num_cols):
            var tile = tile_scene.instance()
            tile.image_data = image_data
            tile.idx = y * num_cols + x
            tile.allow_select_unavailable = allow_select_unavailable
            groups.add_child(tile)
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

    wrapper.scale.x = ratio
    wrapper.scale.y = ratio

    wrapper.position.x = x_delta
    wrapper.position.y = y_delta

func restore_state():
    for tile in tiles:
        tile.restore_state()
    emit_signal("tiles_state_changed")

func generate():
    while true:
        var max_num_available = 0
        var indexes_with_max = []
        for i in range(len(tiles)):
            var num = tiles[i].get_number_of_available_items()
            if num > max_num_available:
                indexes_with_max = [i]
                max_num_available = num
            elif num == max_num_available and num > 0:
                indexes_with_max.append(i)

        if max_num_available == 0:
            break

        if not is_instant_generation:
            yield(get_tree().create_timer(WFC.TRANSITION_ANIM_SPEED + 0.001), "timeout")

        var tile_idx = indexes_with_max[randi() % len(indexes_with_max)]
        tiles[tile_idx].select_random_available_item()
        recursively_update_availability_flags(tile_idx)
        emit_signal("tiles_state_changed")

func select_using_array_of_selections(selections):
    for i in range(0, len(selections), 3):
        var x = selections[i + 0]
        var y = selections[i + 1]
        var item = selections[i + 2]
        if not is_instant_generation:
            yield(get_tree().create_timer(WFC.TRANSITION_ANIM_SPEED + 0.001), "timeout")
        select_item_in_tile(x, y, item)

func select_item_in_tile(x, y, item):
    var tile_idx = y * num_cols + x
    if tile_idx >= 0 and tile_idx < len(tiles):
        tiles[tile_idx].select_item(item)
        recursively_update_availability_flags(tile_idx)
        emit_signal("tiles_state_changed")

func _on_ResetButton_pressed():
    restore_state()

func _on_GenerateButton_pressed():
    generate()
