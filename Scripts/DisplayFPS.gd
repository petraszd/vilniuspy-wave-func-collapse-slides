extends Label


func _ready():
    pass # Replace with function body.


func _process(_delta):
    var items = PoolStringArray([
        "TIME_FPS = %.2f" % Performance.get_monitor(Performance.TIME_FPS),
        "MEMORY_STATIC = %d" % Performance.get_monitor(Performance.MEMORY_STATIC),
        "MEMORY_DYNAMIC = %d" % Performance.get_monitor(Performance.MEMORY_DYNAMIC),
        "MEMORY_STATIC_MAX = %d" % Performance.get_monitor(Performance.MEMORY_STATIC_MAX),
        "MEMORY_DYNAMIC_MAX = %d" % Performance.get_monitor(Performance.MEMORY_DYNAMIC_MAX),
        "MEMORY_MESSAGE_BUFFER_MAX = %d" % Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX),
        "OBJECT_COUNT = %d" % Performance.get_monitor(Performance.OBJECT_COUNT),
        "OBJECT_RESOURCE_COUNT = %d" % Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
        "OBJECT_NODE_COUNT = %d" % Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
        "OBJECT_ORPHAN_NODE_COUNT = %d" % Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),
        "RENDER_OBJECTS_IN_FRAME = %d" % Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME),
        "RENDER_VERTICES_IN_FRAME = %d" % Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME),
        "RENDER_MATERIAL_CHANGES_IN_FRAME = %d" % Performance.get_monitor(Performance.RENDER_MATERIAL_CHANGES_IN_FRAME),
        "RENDER_SHADER_CHANGES_IN_FRAME = %d" % Performance.get_monitor(Performance.RENDER_SHADER_CHANGES_IN_FRAME),
        "RENDER_DRAW_CALLS_IN_FRAME = %d" % Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME),
        "RENDER_2D_ITEMS_IN_FRAME = %d" % Performance.get_monitor(Performance.RENDER_2D_ITEMS_IN_FRAME),
        "RENDER_2D_DRAW_CALLS_IN_FRAME = %d" % Performance.get_monitor(Performance.RENDER_2D_DRAW_CALLS_IN_FRAME),
        "RENDER_VIDEO_MEM_USED = %d" % Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED),
        "RENDER_TEXTURE_MEM_USED = %d" % Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),
        "RENDER_VERTEX_MEM_USED = %d" % Performance.get_monitor(Performance.RENDER_VERTEX_MEM_USED),
        "RENDER_USAGE_VIDEO_MEM_TOTAL = %d" % Performance.get_monitor(Performance.RENDER_USAGE_VIDEO_MEM_TOTAL),
    ])
    text = items.join("\n")
