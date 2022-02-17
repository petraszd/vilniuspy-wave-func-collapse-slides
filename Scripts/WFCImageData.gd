extends Node


export(Texture) var tiles_texture
export(int) var num_img_parts = 1

var img: Image


func _ready():
    assert(num_img_parts > 0)
    # TODO: Image.FORMAT_RGBA8
    img = tiles_texture.get_data()
    assert(img.get_format() == Image.FORMAT_RGB8)
