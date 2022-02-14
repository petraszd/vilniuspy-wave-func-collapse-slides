extends Node2D


func _draw():
    # Consts
    var margin = 10
    var tile_w = 100
    var tile_h = 100

    var img_w = WFCImageData.img.get_width()
    var img_h = WFCImageData.img.get_height()

    var img_part_w = img_w / WFCImageData.num_cols
    var img_part_h = img_h / WFCImageData.num_rows

    var rect = Rect2()
    var rect_src = Rect2()
    for x in range(WFCImageData.num_cols):
        for y in range(WFCImageData.num_rows):
            rect.position.x = margin + x * (tile_w + margin)
            rect.position.y = margin + y * (tile_h + margin)
            rect.size.x = tile_w
            rect.size.y = tile_h

            rect_src.position.x = img_part_w * x
            rect_src.position.y = img_part_h * y
            rect_src.size.x = img_part_w
            rect_src.size.y = img_part_h
            draw_texture_rect_region(WFCImageData.tiles_texture, rect, rect_src)
