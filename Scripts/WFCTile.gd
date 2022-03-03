class_name WFCTile
extends Node2D


class Sizes:
    var segment: float
    var img_part_w: float
    var img_part_h: float
    var item_size: float
    var hover_icon_len: float
    var pos_delta: float

enum TileState {
    NOT_SELECTED,
    SELECTED
}

enum AvailabilityFlag {
    AVAILABLE = 0,
    NOT_AVAILABLE_ANIM = 1,
    NOT_AVAILABLE = 2,
}


const outer_margin = 0.02  # fraction
const inner_margin = 0.05  # fraction
const not_available_color = Color(0.6, 0.6, 0.8, 0.6)
const hovered_color = Color(1.0, 1.0, 1.0, 0.75)
const available_color = Color.white

onready var tween: Tween = get_node("Tween")

# Assigned by collapser
var image_data: WFCImageData = null
var idx: int
var allow_select_unavailable: bool

# Logic
var hovered: int = WFC.NO_INDEX
var selected: int = WFC.NO_INDEX
var current_state: int = TileState.NOT_SELECTED
var availability_flags: PoolByteArray = PoolByteArray()

# Anim helpers
var selected_anim_t: float = 0.0
var not_selected_anim_t: float = 0.0

# Temp vars
var hov_rect = Rect2()
var pos_rect = Rect2()
var tex_rect = Rect2()
var sizes: Sizes
var comp_counters: PoolIntArray = PoolIntArray()


func _ready():
    set_name("Tile %d" % idx)
    sizes = Sizes.new()
    fill_sizes_var()
    fill_availability_flags()
    comp_counters.resize(len(availability_flags))

func _draw():
    var num_img_parts = image_data.num_img_parts
    for y in range(num_img_parts):
        for x in range(num_img_parts):
            var i = y * num_img_parts + x
            draw_item(i, x, y)

func get_modulate_color(i):
    if availability_flags[i] != AvailabilityFlag.AVAILABLE:
        if availability_flags[i] == AvailabilityFlag.NOT_AVAILABLE_ANIM:
            return not_available_color * not_selected_anim_t + available_color * (1.0 - not_selected_anim_t)
        else:
            return not_available_color
    if i == hovered:
        return hovered_color
    return available_color

func draw_item(i, x, y):
    match current_state:
        TileState.NOT_SELECTED:
            if hovered == i:
                draw_hover_indicator(x, y)
            draw_small_item(x, y, get_modulate_color(i))
        TileState.SELECTED:
            if selected_anim_t < 0.0:
                if selected == i:
                    draw_selected_item(x, y)
            else:
                if selected == i:
                    draw_selected_anim_item(x, y, selected_anim_t)
                else:
                    var color = get_modulate_color(i)
                    color.a = color.a * (1.0 - selected_anim_t)
                    draw_small_item(x, y, color)

func draw_small_item(x, y, modulate_color):
    pos_rect.position.x = sizes.pos_delta + x * sizes.segment
    pos_rect.position.y = sizes.pos_delta + y * sizes.segment
    pos_rect.size.x = sizes.item_size
    pos_rect.size.y = sizes.item_size

    tex_rect.position.x = sizes.img_part_w * x
    tex_rect.position.y = sizes.img_part_h * y
    tex_rect.size.x = sizes.img_part_w
    tex_rect.size.y = sizes.img_part_h
    draw_texture_rect_region(
        image_data.tiles_texture,
        pos_rect, tex_rect, modulate_color
    )

func draw_selected_anim_item(x, y, anim_t):
    var pos_x0 = sizes.pos_delta + x * sizes.segment
    var pos_y0 = sizes.pos_delta + y * sizes.segment
    var size_x0 = sizes.item_size
    var size_y0 = sizes.item_size

    var pos_x1 = 0
    var pos_y1 = 0
    var size_x1 = 1
    var size_y1 = 1

    pos_rect.position.x = pos_x0 * (1.0 - anim_t) + pos_x1 * anim_t
    pos_rect.position.y = pos_y0 * (1.0 - anim_t) + pos_y1 * anim_t
    pos_rect.size.x = size_x0 * (1.0 - anim_t) + size_x1 * anim_t
    pos_rect.size.y = size_y0 * (1.0 - anim_t) + size_y1 * anim_t

    # TODO: find out why texture edges looks stupid
    tex_rect.position.x = sizes.img_part_w * x + 0.6
    tex_rect.position.y = sizes.img_part_h * y + 0.6
    tex_rect.size.x = sizes.img_part_w - 0.6
    tex_rect.size.y = sizes.img_part_h - 0.6
    draw_texture_rect_region(image_data.tiles_texture, pos_rect, tex_rect)

func draw_selected_item(x, y):
    pos_rect.position.x = 0
    pos_rect.position.y = 0
    pos_rect.size.x = 1
    pos_rect.size.y = 1

    # TODO: find out why texture edges looks stupid
    tex_rect.position.x = sizes.img_part_w * x + 0.6
    tex_rect.position.y = sizes.img_part_h * y + 0.6
    tex_rect.size.x = sizes.img_part_w - 0.6
    tex_rect.size.y = sizes.img_part_h - 0.6
    draw_texture_rect_region(image_data.tiles_texture, pos_rect, tex_rect)

func draw_hover_indicator(x, y):
    hov_rect.position.x = sizes.pos_delta + x * sizes.segment - sizes.hover_icon_len
    hov_rect.position.y = sizes.pos_delta + y * sizes.segment - sizes.hover_icon_len
    hov_rect.size.x = sizes.item_size + sizes.hover_icon_len * 2
    hov_rect.size.y = sizes.item_size + sizes.hover_icon_len * 2
    draw_rect(hov_rect, Color.white)

func fill_sizes_var():
    var num_img_parts = image_data.num_img_parts

    sizes.segment = (1.0 - outer_margin * 2) / num_img_parts
    sizes.img_part_w = image_data.img.get_width() / num_img_parts
    sizes.img_part_h = image_data.img.get_height() / num_img_parts
    sizes.item_size = sizes.segment - inner_margin * 2 / num_img_parts
    sizes.hover_icon_len = sizes.segment * inner_margin
    sizes.pos_delta = outer_margin + (sizes.segment - sizes.item_size) * 0.5

func fill_availability_flags():
    var n = image_data.num_img_parts * image_data.num_img_parts
    availability_flags.resize(n)
    for i in range(n):
        availability_flags.set(i, AvailabilityFlag.AVAILABLE)

func restore_state():
    hovered = WFC.NO_INDEX
    selected = WFC.NO_INDEX
    current_state = TileState.NOT_SELECTED
    for i in range(len(availability_flags)):
        availability_flags.set(i, AvailabilityFlag.AVAILABLE)
    update()

func process_local_mouse_position(mouse_pos):
    if selected != WFC.NO_INDEX:
        return false

    if (
        mouse_pos.x < outer_margin or
        mouse_pos.y < outer_margin or
        mouse_pos.x > 1.0 - outer_margin or
        mouse_pos.y > 1.0 - outer_margin
    ):
        hovered = WFC.NO_INDEX
    else:
        var num_img_parts = image_data.num_img_parts
        var segment = (1.0 - outer_margin * 2) / num_img_parts

        var int_x = int((mouse_pos.x - outer_margin) / segment)
        var int_y = int((mouse_pos.y - outer_margin) / segment)

        var i = int_y * num_img_parts + int_x

        if (
            allow_select_unavailable or
            availability_flags[i] == AvailabilityFlag.AVAILABLE
        ):
            hovered = i
        else:
            hovered = WFC.NO_INDEX

    update()
    return hovered != WFC.NO_INDEX

func remove_hovered_if_needed():
    if hovered != WFC.NO_INDEX:
        hovered = WFC.NO_INDEX
        update()

func process_click():
    selected = hovered
    hovered = WFC.NO_INDEX
    current_state = TileState.SELECTED
    update()

    selected_anim_t = 0.0
    if (
        tween.interpolate_property(
            self, "selected_anim_t",
            0.0, 1.0, 0.25
        ) and
        tween.start()
    ):
        draw_selected_tween_animation()

func draw_selected_tween_animation():
    while true:
        var step_values = yield(tween, "tween_step")
        update()
        if step_values[3] >= 1:
            selected_anim_t = -1.0
            break

func mark_availability_flags(from_tile, direction):
    if selected != WFC.NO_INDEX:
        return false

    var num_img_parts = image_data.num_img_parts
    var num_items = num_img_parts * num_img_parts
    var comps = image_data.compatibilities

    var from_indexes = []
    if from_tile.selected == WFC.NO_INDEX:
        for i in range(len(from_tile.availability_flags)):
            if from_tile.availability_flags[i] == AvailabilityFlag.AVAILABLE:
                from_indexes.append(i)
    else:
        from_indexes.append(from_tile.selected)

    for i in range(len(availability_flags)):
        comp_counters.set(i, 0)

    for from_idx in from_indexes:
        for to_idx in range(num_img_parts * num_img_parts):
            var comp_idx = from_idx * num_items + to_idx
            var comp = comps[comp_idx]
            if comp & direction:
                comp_counters.set(to_idx, comp_counters[to_idx] + 1)

    var num_disabled = 0
    for i in range(len(availability_flags)):
        if comp_counters[i] == 0:
            if availability_flags[i] == AvailabilityFlag.AVAILABLE:
                num_disabled += 1
                availability_flags.set(i, AvailabilityFlag.NOT_AVAILABLE_ANIM)

    if num_disabled > 0:
        update()
        not_selected_anim_t = 0.0
        if tween.interpolate_property(
            self, "not_selected_anim_t", 0.0, 1.0, 0.25,
            Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
        ) and tween.start():
            draw_not_selected_tween_animation()

        return true
    return false

func draw_not_selected_tween_animation():
    while true:
        var step_values = yield(tween, "tween_step")
        update()
        if step_values[3] >= 1:
            not_selected_anim_t = -1.0
            for i in range(len(availability_flags)):
                if availability_flags[i] == AvailabilityFlag.NOT_AVAILABLE_ANIM:
                    availability_flags.set(i, AvailabilityFlag.NOT_AVAILABLE)
            break
