class_name WFCTile
extends Node2D


var idx: int


func _ready():
    set_name("Tile %d" % idx)

func _draw():
    var rect = Rect2()
    var rect_src = Rect2()

    var num_img_parts = WFCImageData.num_img_parts

    var img_w = WFCImageData.img.get_width()
    var img_h = WFCImageData.img.get_height()

    var img_part_w = img_w / num_img_parts
    var img_part_h = img_h / num_img_parts

    var segment = 1.0 / num_img_parts

    for y in range(num_img_parts):
        for x in range(num_img_parts):
            rect.position.x = x * segment
            rect.position.y = y * segment
            rect.size.x = segment
            rect.size.y = segment

            rect_src.position.x = img_part_w * x
            rect_src.position.y = img_part_h * y
            rect_src.size.x = img_part_w
            rect_src.size.y = img_part_h
            draw_texture_rect_region(WFCImageData.tiles_texture, rect, rect_src)

    draw_debug()

func draw_debug():
    var num_img_parts = WFCImageData.num_img_parts
    for y in range(num_img_parts):
        for x in range(num_img_parts):
            draw_debug_item(x, y)

    var line_color = Color(1.0, 0.0, 0.0)
    draw_line(Vector2(0, 0), Vector2(1, 0), line_color)
    draw_line(Vector2(1, 0), Vector2(1, 1), line_color)
    draw_line(Vector2(1, 1), Vector2(0, 1), line_color)
    draw_line(Vector2(0, 1), Vector2(0, 0), line_color)

func draw_debug_item(x, y):
    var segment = 1.0 / WFCImageData.num_img_parts

    var x0 = segment * x
    var y0 = segment * y

    var x1 = segment * (x + 1)
    var y1 = segment * (y + 1)

    var line_color = Color(0.0, 0.0, 1.0)
    draw_line(Vector2(x0, y0), Vector2(x1, y0), line_color)
    draw_line(Vector2(x1, y0), Vector2(x1, y1), line_color)
    draw_line(Vector2(x1, y1), Vector2(x0, y1), line_color)
    draw_line(Vector2(x0, y1), Vector2(x0, y0), line_color)
