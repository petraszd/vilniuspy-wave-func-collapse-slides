extends Node

onready var editor: WFCPyTextEdit = get_node("HBoxContainer/VBoxContainer/PyTextEdit")
onready var collapser: WFCCollapser = get_node("HBoxContainer/VBoxContainer2/WFCCollapser")
onready var output: TextEdit = get_node("HBoxContainer/VBoxContainer2/Output")

func _on_RunPythonButton_pressed():
    collapser.restore_state()

    output.text = ""

    var image_data = collapser.image_data
    var run_result = WFC.PRunner.run(
        editor.text,
        collapser.num_cols, collapser.num_rows,
        image_data.num_img_parts * image_data.num_img_parts,
        image_data.compatibilities)
    var stdout = run_result[0].join("")
    var stderr = run_result[1].join("")

    if stderr:
        output.text = stderr
    else:
        output.text = stdout
