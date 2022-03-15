extends Node


var current_idx = WFC.NO_INDEX
var next_idx = WFC.NO_INDEX

var slides = [
    preload("res://Scenes/Slides/Slide_01.tscn").instance(),
    preload("res://Scenes/Slides/Slide_02.tscn").instance(),
]

onready var slides_wrapper: Control = get_node("SlidesWrapper")
onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")


func _ready():
    assert(slides.size() > 0)
    _set_next_slide(0)

func _unhandled_input(event):
    var owner = slides_wrapper.get_focus_owner()
    if owner != null and owner.get_class() == "TextEdit":
        return

    if anim_player.is_playing():
        return

    if _is_asking_for_next_slide(event):
        if current_idx < slides.size() - 1:
            _set_next_slide(current_idx + 1)
    elif _is_asking_for_prev_slide(event):
        if current_idx > 0:
            _set_next_slide(current_idx - 1)

func switch_current_to_next():
    var current_slide = slides[current_idx]
    var next_slide = slides[next_idx]

    slides_wrapper.add_child(next_slide)
    slides_wrapper.remove_child(current_slide)

    current_idx = next_idx
    next_idx = WFC.NO_INDEX

func _set_next_slide(idx):
    if current_idx == WFC.NO_INDEX:
        current_idx = idx
        slides_wrapper.add_child(slides[idx])
        return

    next_idx = idx
    anim_player.play("ChangeSlides")

func _is_asking_for_next_slide(event):
    return (
        event.is_action_released("ui_accept") or
        event.is_action_released("ui_right")
    )

func _is_asking_for_prev_slide(event):
    return event.is_action_released("ui_left")
