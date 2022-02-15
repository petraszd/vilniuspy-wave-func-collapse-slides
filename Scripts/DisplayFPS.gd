extends Label


func _ready():
    pass # Replace with function body.


func _process(_delta):
    text = "FPS = %.2f" % Performance.get_monitor(Performance.TIME_FPS)
