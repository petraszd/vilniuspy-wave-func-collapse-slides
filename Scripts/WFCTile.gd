class_name WFCTile
extends Node2D


const outer_margin = 0.02  # fraction
const inner_margin = 0.05  # fraction
const NO_INDEX = -1

var idx: int

var hovered: int = NO_INDEX


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

    var delta = outer_margin + (segment - item_size) * 0.5

    for y in range(num_img_parts):
        for x in range(num_img_parts):
            pos_rect.position.x = delta + x * segment
            pos_rect.position.y = delta + y * segment
            pos_rect.size.x = item_size
            pos_rect.size.y = item_size

            tex_rect.position.x = img_part_w * x
            tex_rect.position.y = img_part_h * y
            tex_rect.size.x = img_part_w
            tex_rect.size.y = img_part_h

            var modulate_color: Color
            if hovered == y * num_img_parts + x:
                modulate_color = Color(1, 1, 1, 0.5)
            else:
                modulate_color = Color(1, 1, 1, 1)
            draw_texture_rect_region(
                WFCImageData.tiles_texture,
                pos_rect, tex_rect, modulate_color
            )

    #draw_debug()

func draw_debug():
    var line_color = Color(1.0, 0.4, 0.4)
    draw_line(Vector2(0, 0), Vector2(1, 0), line_color)
    draw_line(Vector2(1, 0), Vector2(1, 1), line_color)
    draw_line(Vector2(1, 1), Vector2(0, 1), line_color)
    draw_line(Vector2(0, 1), Vector2(0, 0), line_color)

func process_local_mouse_position(mouse_pos):
    if (
        mouse_pos.x < outer_margin or
        mouse_pos.y < outer_margin or
        mouse_pos.x > 1.0 - outer_margin or
        mouse_pos.y > 1.0 - outer_margin
    ):
        hovered = NO_INDEX
    else:
        var num_img_parts = WFCImageData.num_img_parts
        var segment = (1.0 - outer_margin * 2) / num_img_parts

        var int_x = int((mouse_pos.x - outer_margin) / segment)
        var int_y = int((mouse_pos.y - outer_margin) / segment)

        hovered = int_y * num_img_parts + int_x

    update()
    return hovered != NO_INDEX

func remove_hovered():
    hovered = NO_INDEX
    update()


func process_click():
    # TODO: continue
    print("CLICKED ON ", hovered)
