extends Button


func _on_pressed():
    #var result: PoolStringArray = WFC.PRunner.get_foobar()
    var result = WFC.PRunner.run()
    var stdout = result[0]
    var stderr = result[1]
    print("*******************")
    print(stdout.join(""))
    print(stderr.join(""))
