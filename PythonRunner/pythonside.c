#define PY_SSIZE_T_CLEAN
#include <Python.h>

#include "pythonside.h"


static PyObject* common_write(PyObject* mod, PyObject* args)
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

    output_module_state_t* state = PyModule_GetState(mod);
    state->callback(state->user_data, utf8_string);

    return Py_None;
}

static PyObject* common_flush(PyObject* mod, PyObject* args)
{
    // Do not care
    return Py_None;
}

// STDOUT

static PyMethodDef stdout_capture_methods[] =
{
    {
        .ml_name  = "write",
        .ml_meth  = &common_write,
        .ml_flags = METH_VARARGS,
        .ml_doc   = NULL,
    },
    {
        .ml_name  = "flush",
        .ml_meth  = &common_flush,
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
    .m_size     = sizeof(output_module_state_t),
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

// STDERR

static PyMethodDef stderr_capture_methods[] =
{
    {
        .ml_name  = "write",
        .ml_meth  = &common_write,
        .ml_flags = METH_VARARGS,
        .ml_doc   = NULL,
    },
    {
        .ml_name  = "flush",
        .ml_meth  = &common_flush,
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

static PyModuleDef stderr_capture_module = {
    .m_base     = PyModuleDef_HEAD_INIT,
    .m_name     = "stderr_capture",
    .m_doc      = NULL,
    .m_size     = sizeof(output_module_state_t),
    .m_methods  = stderr_capture_methods,
    .m_slots    = NULL,
    .m_traverse = NULL,
    .m_clear    = NULL,
    .m_free     = NULL,
};

PyObject* create_stderr_capture_module()
{
    return PyModule_Create(&stderr_capture_module);
}

int pside_run_code(
        void* user_data,
        output_callback_t stdout_callback,
        output_callback_t stderr_callback
        )
{
    /* TODO: PyImport_AppendInittab("stderr_capture");*/
    if (PyImport_AppendInittab("stdout_capture", &create_stdout_capture_module) == -1) {
        return -1;
    }
    if (PyImport_AppendInittab("stderr_capture", &create_stderr_capture_module) == -1) {
        return -1;
    }
    // TODO: Py_SetProgramName(...);
    Py_Initialize();

    PyObject* stdout_module = PyImport_ImportModule("stdout_capture");
    output_module_state_t* stdout_state = PyModule_GetState(stdout_module);
    stdout_state->user_data = user_data;
    stdout_state->callback = stdout_callback;

    PyObject* stderr_module = PyImport_ImportModule("stderr_capture");
    output_module_state_t* stderr_state = PyModule_GetState(stderr_module);
    stderr_state->user_data = user_data;
    stderr_state->callback = stderr_callback;

    PyRun_SimpleString(
            "import sys\n"
            "import stdout_capture\n"
            "import stderr_capture\n"
            "sys.stdout = stdout_capture\n"
            "sys.stderr = stderr_capture\n"
            );

    PyRun_SimpleString("print('Hello Sailor!!!')");
    PyRun_SimpleString("a += b.foobar");

    return Py_FinalizeEx() < 0 ? -1 : 0;
}
