#define PY_SSIZE_T_CLEAN
#include <Python.h>

#include "pythonside.h"


static PyObject* common_write(PyObject* p_mod, PyObject* p_args)
{
    Py_ssize_t args_size = PyTuple_Size(p_args);
    if (args_size == 0) {
        return Py_None;
    }

    PyObject *python_string = PyTuple_GetItem(p_args, 0);
    Py_INCREF(python_string);
    Py_ssize_t python_string_len = PyUnicode_GetLength(python_string);

    Py_ssize_t utf8_string_len;
    // According to docs there is no need to free utf8_str
    const char *utf8_string = PyUnicode_AsUTF8AndSize(python_string, &utf8_string_len);
    Py_DECREF(python_string);

    assert(utf8_string_len > 0);
    assert(utf8_string != NULL);
    assert(utf8_string_len >= python_string_len);

    output_module_state_t* state = PyModule_GetState(p_mod);
    state->callback(state->user_data, utf8_string);

    return Py_None;
}

static PyObject* common_flush(PyObject* p_mod, PyObject* p_args)
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
        void* p_user_data,
        output_callback_t p_stdout_callback,
        output_callback_t p_stderr_callback,
        result_callback_t p_result_callback,
        function_args_t* p_function_args)
{
    /* -- Initing -- */
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
    stdout_state->user_data = p_user_data;
    stdout_state->callback = p_stdout_callback;
    Py_DECREF(stdout_module);

    PyObject* stderr_module = PyImport_ImportModule("stderr_capture");
    output_module_state_t* stderr_state = PyModule_GetState(stderr_module);
    stderr_state->user_data = p_user_data;
    stderr_state->callback = p_stderr_callback;
    Py_DECREF(stderr_module);

    PyRun_SimpleString(
            "import sys\n"
            "import stdout_capture\n"
            "import stderr_capture\n"
            "sys.stdout = stdout_capture\n"
            "sys.stderr = stderr_capture\n"
            );

    /* -- Running code -- */

    char temp[2048];
    sprintf(temp, "num_cols = %d", p_function_args->num_cols);
    PyRun_SimpleString(temp);

    sprintf(temp, "num_rows = %d", p_function_args->num_rows);
    PyRun_SimpleString(temp);

    sprintf(temp, "num_image_fragments = %d", p_function_args->num_image_fragments);
    PyRun_SimpleString(temp);

    sprintf(temp, "num_compatibilities = %d", p_function_args->num_compatibilities);
    PyRun_SimpleString(temp);

    int delta = sprintf(temp, "compatibilities = [");
    for (int i = 0; i < p_function_args->num_compatibilities; ++i) {
        delta += sprintf(temp + delta, "%d,", p_function_args->compatibilities[i]);
    }
    sprintf(temp + delta, "]");
    PyRun_SimpleString(temp);

    sprintf(temp, "print(num_cols, num_rows, num_image_fragments, num_compatibilities, compatibilities)");
    PyRun_SimpleString(temp);

    sprintf(temp, "result = 42"); /* TODO call function */
    PyRun_SimpleString(temp);

    /* -- Extracting result -- */
    PyObject* main_module = PyImport_ImportModule("__main__");
    PyObject* main_dict = PyModule_GetDict(main_module);
    Py_DECREF(main_module);
    PyObject* result = PyDict_GetItemString(main_dict, "result");

    if (result->ob_type == &PyLong_Type) {
        p_result_callback(p_user_data, NULL /* TODO */, (int)(PyLong_AsLong(result)));
    } else {
        return -1;
    }

    return Py_FinalizeEx() < 0 ? -1 : 0;
}
