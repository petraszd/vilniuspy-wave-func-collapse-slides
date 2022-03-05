class_name WFCTileErrors
extends Node2D


var error_rects: Array = []
var image_data: WFCImageData = null

func _draw():
    for rect in error_rects:
        draw_rect(rect, Color.red)
    print("DRAW")

func _on_tiles_state_changed(tiles, num_cols, num_rows):
    error_rects.clear()

    var num_items = image_data.num_img_parts * image_data.num_img_parts
    for y in range(num_rows):
        for x in range(num_cols):
            var tile = tiles[y * num_cols + x]
            if tile.selected == WFC.NO_INDEX:
                continue

            var from_idx = tile.selected
            if y < num_rows - 1:
                var bottom_tile = tiles[(y + 1) * num_cols + x]
                if bottom_tile.selected != WFC.NO_INDEX:
                    var to_idx = bottom_tile.selected
                    var comp_idx = from_idx * num_items + to_idx
                    if (image_data.compatibilities[comp_idx] & WFC.Directions.FROM_TOP_TO_BOTTOM) == 0:
                        var rect = Rect2()
                        rect.position.x = x
                        rect.position.y = y + 1
                        rect.size.x = 1
                        rect.size.y = 0.1
                        error_rects.append(rect)

            if x < num_cols - 1:
                var right_tile = tiles[y * num_cols + x + 1]
                if right_tile.selected != WFC.NO_INDEX:
                    var to_idx = right_tile.selected
                    var comp_idx = from_idx * num_items + to_idx
                    if (image_data.compatibilities[comp_idx] & WFC.Directions.FROM_RIGHT_TO_LEFT) == 0:
                        var rect = Rect2()
                        rect.position.x = x + 1
                        rect.position.y = y
                        rect.size.x = 0.1
                        rect.size.y = 1
                        error_rects.append(rect)

    update()
