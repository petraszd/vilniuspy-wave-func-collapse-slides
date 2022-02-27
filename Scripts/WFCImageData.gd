extends Node


class ColorInfo:
    var top: Array = []
    var bottom: Array = []
    var right: Array = []
    var left: Array = []

    func compatibility(other):
        return (
            from_top_to_bottom(other) |
            from_bottom_to_top(other) |
            from_right_to_left(other) |
            from_left_to_right(other)
        )

    func from_top_to_bottom(other):
        return _from_dir0_to_dir1(self.bottom, other.top, WFC.Directions.FROM_TOP_TO_BOTTOM)

    func from_bottom_to_top(other):
        return _from_dir0_to_dir1(self.top, other.bottom, WFC.Directions.FROM_BOTTOM_TO_TOP)

    func from_right_to_left(other):
        return _from_dir0_to_dir1(self.left, other.right, WFC.Directions.FROM_RIGHT_TO_LEFT)

    func from_left_to_right(other):
        return _from_dir0_to_dir1(self.right, other.left, WFC.Directions.FROM_LEFT_TO_RIGHT)

    func _from_dir0_to_dir1(dir0, dir1, positive_result):
        for i in range(len(dir0)):
            if abs(dir0[i] - dir1[i]) >= 5: # TODO: epsilosn
                return 0
        return positive_result


const num_points_for_compatibilities = 4

export(Texture) var tiles_texture
export(int) var num_img_parts = 1  # TODO: rename num_side_parts

var img: Image
var compatibilities: Array = []


func _ready():
    assert(num_img_parts > 0)
    # TODO: Image.FORMAT_RGBA8
    img = tiles_texture.get_data()
    assert(img.get_format() == Image.FORMAT_RGBA8)
    calculate_compatibilities()

func calculate_compatibilities():
    var color_infos = get_color_infos()
    var num_items = num_img_parts * num_img_parts  # TODO: rename after num_img_parts is renamed
    var num_compatibilities = num_items * num_items
    compatibilities.resize(num_compatibilities)

    for y0 in range(num_img_parts):
        for x0 in range(num_img_parts):
            var from_idx = y0 * num_img_parts + x0
            for y1 in range(num_img_parts):
                for x1 in range(num_img_parts):
                    var to_idx = y1 * num_img_parts + x1
                    var comp_idx = from_idx * num_items + to_idx
                    compatibilities[comp_idx] = color_infos[from_idx].compatibility(
                        color_infos[to_idx]
                    )

func get_color_infos():
    var bytes: PoolByteArray = img.get_data()

    var w = img.get_width()
    var h = img.get_height()
    var img_part_w = img.get_width() / num_img_parts
    var w_step = img_part_w / (num_points_for_compatibilities - 1)
    var img_part_h = img.get_height() / num_img_parts
    var h_step = img_part_h / (num_points_for_compatibilities - 1)

    var color_infos = []
    for y in range(num_img_parts):
        for x in range(num_img_parts):
            var info = ColorInfo.new()
            color_infos.append(info)
            var x0 = x * img_part_w
            var x1 = (x + 1) * img_part_w - 1
            var y0 = y * img_part_h
            var y1 = (y + 1) * img_part_h - 1

            for c in range(num_points_for_compatibilities):
                var x2 = c * w_step
                var y2 = c * h_step

                # Top
                var top_idx = (y0 * w + x0 + x2) * 4
                info.top.append(bytes[top_idx + 0])
                info.top.append(bytes[top_idx + 1])
                info.top.append(bytes[top_idx + 2])

                # Bottom
                var bottom_idx = (y1 * w + x0 + x2) * 4
                info.bottom.append(bytes[bottom_idx + 0])
                info.bottom.append(bytes[bottom_idx + 1])
                info.bottom.append(bytes[bottom_idx + 2])

                # Right
                var right_idx = ((y0 + y2) * h + x1) * 4
                info.right.append(bytes[right_idx + 0])
                info.right.append(bytes[right_idx + 1])
                info.right.append(bytes[right_idx + 2])

                # Left
                var left_idx = ((y0 + y2) * h + x0) * 4
                info.left.append(bytes[left_idx + 0])
                info.left.append(bytes[left_idx + 1])
                info.left.append(bytes[left_idx + 2])

    return color_infos
