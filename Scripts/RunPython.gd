extends Button


func _on_pressed():
    #var result: PoolStringArray = WFC.PRunner.get_foobar()
    var result = WFC.PRunner.run()
    var stdout = result[0].join("")
    var stderr = result[1].join("")

    if stderr:
        print("ERROR")
        print(stderr)
    else:
        print("GOOD")
        print(stdout)
