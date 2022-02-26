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
    INIT, SELECTED_ANIMATING, SELECTED
}


const outer_margin = 0.02  # fraction
const inner_margin = 0.05  # fraction

onready var tween: Tween = get_node("Tween")

var idx: int

var hovered: int = WFC.NO_INDEX
var selected: int = WFC.NO_INDEX
var current_state: int = TileState.INIT

var selected_anim_t: float = 0.0

var hov_rect = Rect2()
var pos_rect = Rect2()
var tex_rect = Rect2()
var sizes: Sizes


func _ready():
    set_name("Tile %d" % idx)
    sizes = Sizes.new()
    fill_sizes_var()

func _draw():
    var num_img_parts = WFCImageData.num_img_parts
    for y in range(num_img_parts):
        for x in range(num_img_parts):
            var i = y * num_img_parts + x
            draw_item(i, x, y)

func draw_item(i, x, y):
    match current_state:
        TileState.INIT:
            if hovered == i:
                draw_hover_indicator(x, y)
                draw_small_item(x, y, Color(1, 1, 1, 0.75))  # TODO: to const
            else:
                draw_small_item(x, y, Color.white)
        TileState.SELECTED_ANIMATING:
            if selected == i:
                draw_selected_anim_item(x, y, selected_anim_t)
            else:
                draw_small_item(x, y, Color(1, 1, 1, 1.0 - selected_anim_t))
        TileState.SELECTED:
            if selected == i:
                draw_selected_item(x, y)

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
        WFCImageData.tiles_texture,
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
    draw_texture_rect_region(WFCImageData.tiles_texture, pos_rect, tex_rect)

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
    draw_texture_rect_region(WFCImageData.tiles_texture, pos_rect, tex_rect)

func draw_hover_indicator(x, y):
    hov_rect.position.x = sizes.pos_delta + x * sizes.segment - sizes.hover_icon_len
    hov_rect.position.y = sizes.pos_delta + y * sizes.segment - sizes.hover_icon_len
    hov_rect.size.x = sizes.item_size + sizes.hover_icon_len * 2
    hov_rect.size.y = sizes.item_size + sizes.hover_icon_len * 2
    draw_rect(hov_rect, Color(1, 1, 1, 1))

func fill_sizes_var():
    var num_img_parts = WFCImageData.num_img_parts

    sizes.segment = (1.0 - outer_margin * 2) / num_img_parts
    sizes.img_part_w = WFCImageData.img.get_width() / num_img_parts
    sizes.img_part_h = WFCImageData.img.get_height() / num_img_parts
    sizes.item_size = sizes.segment - inner_margin * 2 / num_img_parts
    sizes.hover_icon_len = sizes.segment * inner_margin
    sizes.pos_delta = outer_margin + (sizes.segment - sizes.item_size) * 0.5

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
        var num_img_parts = WFCImageData.num_img_parts
        var segment = (1.0 - outer_margin * 2) / num_img_parts

        var int_x = int((mouse_pos.x - outer_margin) / segment)
        var int_y = int((mouse_pos.y - outer_margin) / segment)

        hovered = int_y * num_img_parts + int_x

    update()
    return hovered != WFC.NO_INDEX

func remove_hovered_if_needed():
    if hovered != WFC.NO_INDEX:
        hovered = WFC.NO_INDEX
        update()

func process_click():
    # TODO: continue
    selected = hovered
    hovered = WFC.NO_INDEX
    current_state = TileState.SELECTED_ANIMATING
    update()

    if not tween.interpolate_property(self, "selected_anim_t", 0.0, 1.0, 0.25):
        print("Warning: tween does not work!")
    if not tween.start():
        print("Warning: tween does not work!")
    draw_tween_animation()


func draw_tween_animation():
    while true:
        var step_values = yield(tween, "tween_step")
        update()
        if step_values[3] >= 1:
            break
