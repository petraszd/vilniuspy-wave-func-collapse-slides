class_name WFCTile
extends Node2D


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


func _ready():
    set_name("Tile %d" % idx)

func _draw():
    var pos_rect = Rect2()
    var tex_rect = Rect2()

    var num_img_parts = WFCImageData.num_img_parts

    var img_w = WFCImageData.img.get_width()
    var img_h = WFCImageData.img.get_height()

    var img_part_w = img_w / num_img_parts
    var img_part_h = img_h / num_img_parts

    var segment = (1.0 - outer_margin * 2) / num_img_parts
    var item_size = segment - inner_margin * 2 / num_img_parts
    var hover_icon_len = segment * inner_margin

    var delta = outer_margin + (segment - item_size) * 0.5

    for y in range(num_img_parts):
        for x in range(num_img_parts):
            var modulate_color: Color
            var i = y * num_img_parts + x
            if hovered == i:
                pos_rect.position.x = delta + x * segment - hover_icon_len
                pos_rect.position.y = delta + y * segment - hover_icon_len
                pos_rect.size.x = item_size + hover_icon_len * 2
                pos_rect.size.y = item_size + hover_icon_len * 2
                draw_rect(pos_rect, Color(1, 1, 1, 1))
                modulate_color = Color(1, 1, 1, 0.75)
            elif current_state == TileState.SELECTED_ANIMATING:
                if selected == i:
                    modulate_color = Color(1, 1, 1, 1)
                else:
                    modulate_color = Color(1, 1, 1, 1.0 - selected_anim_t)
            else:
                modulate_color = Color(1, 1, 1, 1)

            pos_rect.position.x = delta + x * segment
            pos_rect.position.y = delta + y * segment
            pos_rect.size.x = item_size
            pos_rect.size.y = item_size

            tex_rect.position.x = img_part_w * x
            tex_rect.position.y = img_part_h * y
            tex_rect.size.x = img_part_w
            tex_rect.size.y = img_part_h

            draw_texture_rect_region(
                WFCImageData.tiles_texture,
                pos_rect, tex_rect, modulate_color
            )


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

    if not tween.interpolate_property(self, "selected_anim_t", 0.0, 1.0, 0.5):
        print("Warning: tween does not work!")
    if not tween.start():
        print("Warning: tween does not work!")
    foobar()


func foobar():
    while true:
        var step_values = yield(tween, "tween_step")
        update()
        if step_values[3] >= 1:
            break
