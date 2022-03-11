.DEFAULT_GOAL := compile

RUNNER_SRC = runner.c
PYTHONSIDE_SRC = pythonside.c

ALL_SRC = $(RUNNER_SRC) $(PYTHONSIDE_SRC)

COMPILE_ARGS = -I./ -I./godot-headers `python3.9-config --includes` -std=c11 -Wall -fPIC -c
OPTIMIZATION = -g
#OPTIMIZATION = -o2

compile:
	clang $(COMPILE_ARGS) $(OPTIMIZATION) -o runner.os $(RUNNER_SRC)
	clang $(COMPILE_ARGS) $(OPTIMIZATION) -o pythonside.os $(PYTHONSIDE_SRC)
	clang -dynamiclib runner.os pythonside.os `python3.9-config --configdir`/libpython3.9.dylib -o ../NativeLibs/PythonRunner.dylib

generate-compilation-db:
	clang -MJ compile_commands.json $(COMPILE_ARGS) $(ALL_SRC)
	rm -f a.out
	rm -f runner.o
	rm -f pythonside.o
	python3 -c 'print("[" + ", ".join([x.strip(" ,\n") for x in open("compile_commands.json", "r").readlines()]) + "]")' > temp.json
	cat temp.json > compile_commands.json
	rm temp.json
