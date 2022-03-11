#define PY_SSIZE_T_CLEAN
#include <Python.h>

#include "pythonside.h"


// TODO: to .h file
typedef struct {
    output_callback_t callback;
} my_module_state;


static PyObject* stdout_write(PyObject* mod, PyObject* args)
{
    Py_ssize_t args_size = PyTuple_Size(args);
    if (args_size == 0) {
        return Py_None;
    }

    PyObject *python_string = PyTuple_GetItem(args, 0);
    Py_INCREF(python_string);
    Py_ssize_t python_string_len = PyUnicode_GetLength(python_string);

    Py_ssize_t utf8_string_len;
    // According to docs there is no need to free utf8_str
    const char *utf8_string = PyUnicode_AsUTF8AndSize(python_string, &utf8_string_len);
    Py_DECREF(python_string);

    assert(utf8_string_len > 0);
    assert(utf8_string != NULL);
    assert(utf8_string_len >= python_string_len);

    my_module_state* state = PyModule_GetState(mod);
    state->callback("HELLO FROM WITHIN");

    /*size_t stdout_available_space = PIPE_SIZE - stdout_pipe_idx;*/
    /*strncpy(*/
            /*stdout_pipe + stdout_pipe_idx,*/
            /*utf8_str,*/
            /*n_utf8_str > stdout_available_space ? stdout_available_space: n_utf8_str);*/
    /*stdout_pipe[PIPE_SIZE] = '\0';*/
    /*stdout_pipe_idx += n_utf8_str;*/

    return Py_None;
}

static PyObject* stdout_flush(PyObject* mod, PyObject* args)
{
    // Do not care
    return Py_None;
}

static PyMethodDef stdout_capture_methods[] =
{
    {
        .ml_name  = "write",
        .ml_meth  = &stdout_write,
        .ml_flags = METH_VARARGS,
        .ml_doc   = NULL,
    },
    {
        .ml_name  = "flush",
        .ml_meth  = &stdout_flush,
        .ml_flags = METH_VARARGS,
        .ml_doc   = NULL,
    },
    {
        .ml_name  = NULL,
        .ml_meth  = NULL,
        .ml_flags = 0,
        .ml_doc   = NULL,
    }
};

static PyModuleDef stdout_capture_module = {
    .m_base     = PyModuleDef_HEAD_INIT,
    .m_name     = "stdout_capture",
    .m_doc      = NULL,
    .m_size     = sizeof (my_module_state),
    .m_methods  = stdout_capture_methods,
    .m_slots    = NULL,
    .m_traverse = NULL,
    .m_clear    = NULL,
    .m_free     = NULL,
};

PyObject* create_stdout_capture_module()
{
    return PyModule_Create(&stdout_capture_module);
}

int pside_run_code(output_callback_t callback)
{
    /* TODO: PyImport_AppendInittab("stderr_capture");*/
    if (PyImport_AppendInittab("stdout_capture", &create_stdout_capture_module) == -1) {
        return -1;
    }
    Py_Initialize();

    /* WTF I Am doing? */
    PyObject* module = PyImport_ImportModule("stdout_capture");
    my_module_state* state = PyModule_GetState(module);
    state->callback = callback;
    /* WTF end */

    PyRun_SimpleString(
            "import sys\n"
            "import stdout_capture\n"
            "sys.stdout = stdout_capture\n"
            );


    PyRun_SimpleString("print('BYBIS')");

    callback("pside_run_code"); // TODO :remove

    return Py_FinalizeEx() < 0 ? -1 : 0;
}
