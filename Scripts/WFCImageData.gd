extends Node


export(Texture) var tiles_texture
export(int) var num_img_parts = 1

var img: Image


func _ready():
    # TODO: Image.FORMAT_RGBA8
    img = tiles_texture.get_data()
    assert(img.get_format() == Image.FORMAT_RGB8)

    print("ImageData: %dx%d" % [img.get_width(), img.get_height()])
    print("Split Image into %dx%d" % [num_img_parts, num_img_parts])